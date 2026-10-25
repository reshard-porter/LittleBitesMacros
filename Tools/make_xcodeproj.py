#!/usr/bin/env python3
"""Writes LittleBitesMacros.xcodeproj without needing Xcode or XcodeGen.

Uses Xcode 16 folder-synchronized groups, so every file in LittleBitesMacros/, Shared/ and
LittleBitesWidgets/ is included automatically. Requires Xcode 16 or later.

Usage:  python3 Tools/make_xcodeproj.py
"""

import hashlib
import os
import re

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
APP, EXT = "LittleBitesMacros", "LittleBitesWidgets"
BUNDLE_ID = "com.example.LittleBitesMacros"
DEPLOYMENT = "18.0"


def oid(name):
    return hashlib.md5(name.encode()).hexdigest()[:24].upper()


objects = {}


def obj(ident, **fields):
    key = oid(ident)
    objects[key] = fields
    return key


# --- Groups ---------------------------------------------------------------------------------
sync = {folder: obj(f"sync:{folder}", isa="PBXFileSystemSynchronizedRootGroup", path=folder, sourceTree="<group>")
        for folder in [APP, "Shared", EXT, "Config"]}
app_product = obj("product:app", isa="PBXFileReference", explicitFileType="wrapper.application",
                  includeInIndex="0", path=f"{APP}.app", sourceTree="BUILT_PRODUCTS_DIR")
ext_product = obj("product:ext", isa="PBXFileReference", explicitFileType='"wrapper.app-extension"',
                  includeInIndex="0", path=f"{EXT}.appex", sourceTree="BUILT_PRODUCTS_DIR")
products = obj("group:products", isa="PBXGroup", children=[app_product, ext_product], name="Products",
               sourceTree="<group>")
main_group = obj("group:main", isa="PBXGroup",
                 children=[sync[APP], sync["Shared"], sync[EXT], sync["Config"], products], sourceTree="<group>")


# --- Build phases ---------------------------------------------------------------------------
def phase(ident, isa, **extra):
    return obj(ident, isa=isa, buildActionMask="2147483647", files=[], runOnlyForDeploymentPostprocessing="0", **extra)


embed_file = obj("buildfile:embed-ext", isa="PBXBuildFile", fileRef=ext_product,
                 settings={"ATTRIBUTES": ["RemoveHeadersOnCopy"]})
app_phases = [phase("phase:app:sources", "PBXSourcesBuildPhase"),
              phase("phase:app:frameworks", "PBXFrameworksBuildPhase"),
              phase("phase:app:resources", "PBXResourcesBuildPhase")]
embed_phase = obj("phase:app:embed", isa="PBXCopyFilesBuildPhase", buildActionMask="2147483647", dstPath='""',
                  dstSubfolderSpec="13", files=[embed_file], name='"Embed Foundation Extensions"',
                  runOnlyForDeploymentPostprocessing="0")
ext_phases = [phase("phase:ext:sources", "PBXSourcesBuildPhase"),
              phase("phase:ext:frameworks", "PBXFrameworksBuildPhase"),
              phase("phase:ext:resources", "PBXResourcesBuildPhase")]

# --- Build settings -------------------------------------------------------------------------
common = {
    "ALWAYS_SEARCH_USER_PATHS": "NO",
    "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
    "CLANG_ENABLE_MODULES": "YES",
    "CLANG_ENABLE_OBJC_ARC": "YES",
    "COPY_PHASE_STRIP": "NO",
    "ENABLE_STRICT_OBJC_MSGSEND": "YES",
    "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
    "GCC_C_LANGUAGE_STANDARD": "gnu17",
    "IPHONEOS_DEPLOYMENT_TARGET": DEPLOYMENT,
    "LOCALIZATION_PREFERS_STRING_CATALOGS": "YES",
    "MTL_FAST_MATH": "YES",
    "SDKROOT": "iphoneos",
    "SWIFT_VERSION": "6.0",
}
project_debug = dict(common, **{
    "DEBUG_INFORMATION_FORMAT": "dwarf",
    "ENABLE_TESTABILITY": "YES",
    "GCC_OPTIMIZATION_LEVEL": "0",
    "GCC_PREPROCESSOR_DEFINITIONS": ["DEBUG=1", "$(inherited)"],
    "MTL_ENABLE_DEBUG_INFO": "INCLUDE_SOURCE",
    "ONLY_ACTIVE_ARCH": "YES",
    "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "DEBUG $(inherited)",
    "SWIFT_OPTIMIZATION_LEVEL": "-Onone",
})
project_release = dict(common, **{
    "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
    "ENABLE_NS_ASSERTIONS": "NO",
    "MTL_ENABLE_DEBUG_INFO": "NO",
    "SWIFT_COMPILATION_MODE": "wholemodule",
    "VALIDATE_PRODUCT": "YES",
})
shared_target = {
    "CODE_SIGN_STYLE": "Automatic",
    "CURRENT_PROJECT_VERSION": "2",
    "DEVELOPMENT_TEAM": "",
    "GENERATE_INFOPLIST_FILE": "YES",
    "MARKETING_VERSION": "1.1",
    "PRODUCT_NAME": "$(TARGET_NAME)",
    "SWIFT_EMIT_LOC_STRINGS": "YES",
    "SWIFT_VERSION": "6.0",
    "TARGETED_DEVICE_FAMILY": "1",
}
app_settings = dict(shared_target, **{
    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
    "CODE_SIGN_ENTITLEMENTS": f"Config/{APP}.entitlements",
    "INFOPLIST_FILE": f"Config/{APP}-Info.plist",
    "INFOPLIST_KEY_CFBundleDisplayName": "LittleBites",
    "INFOPLIST_KEY_NSCameraUsageDescription": "LittleBites uses the camera to scan grocery receipts and move items into your pantry.",
    "INFOPLIST_KEY_NSSupportsLiveActivities": "YES",
    "INFOPLIST_KEY_UIApplicationSceneManifest_Generation": "YES",
    "INFOPLIST_KEY_UILaunchScreen_Generation": "YES",
    "INFOPLIST_KEY_UISupportedInterfaceOrientations": "UIInterfaceOrientationPortrait",
    "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks"],
    "PRODUCT_BUNDLE_IDENTIFIER": BUNDLE_ID,
})
ext_settings = dict(shared_target, **{
    "CODE_SIGN_ENTITLEMENTS": f"Config/{EXT}.entitlements",
    "INFOPLIST_FILE": f"Config/{EXT}-Info.plist",
    "INFOPLIST_KEY_CFBundleDisplayName": "LittleBites Widgets",
    "INFOPLIST_KEY_NSHumanReadableCopyright": "",
    "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)", "@executable_path/Frameworks", "@executable_path/../../Frameworks"],
    "PRODUCT_BUNDLE_IDENTIFIER": f"{BUNDLE_ID}.Widgets",
    "SKIP_INSTALL": "YES",
})


def config_list(name, debug, release):
    d = obj(f"config:{name}:debug", isa="XCBuildConfiguration", buildSettings=debug, name="Debug")
    r = obj(f"config:{name}:release", isa="XCBuildConfiguration", buildSettings=release, name="Release")
    return obj(f"configlist:{name}", isa="XCConfigurationList", buildConfigurations=[d, r],
               defaultConfigurationIsVisible="0", defaultConfigurationName="Release")


# --- Targets & project ----------------------------------------------------------------------
project_key = oid("project")
ext_target = obj("target:ext", isa="PBXNativeTarget",
                 buildConfigurationList=config_list("ext", ext_settings, ext_settings),
                 buildPhases=ext_phases, buildRules=[], dependencies=[],
                 fileSystemSynchronizedGroups=[sync[EXT], sync["Shared"]],
                 name=EXT, packageProductDependencies=[], productName=EXT,
                 productReference=ext_product, productType='"com.apple.product-type.app-extension"')
proxy = obj("proxy:ext", isa="PBXContainerItemProxy", containerPortal=project_key, proxyType="1",
            remoteGlobalIDString=ext_target, remoteInfo=EXT)
dependency = obj("dependency:ext", isa="PBXTargetDependency", target=ext_target, targetProxy=proxy)
app_target = obj("target:app", isa="PBXNativeTarget",
                 buildConfigurationList=config_list("app", app_settings, app_settings),
                 buildPhases=app_phases + [embed_phase], buildRules=[], dependencies=[dependency],
                 fileSystemSynchronizedGroups=[sync[APP], sync["Shared"]],
                 name=APP, packageProductDependencies=[], productName=APP,
                 productReference=app_product, productType='"com.apple.product-type.application"')
objects[project_key] = dict(
    isa="PBXProject",
    attributes={
        "BuildIndependentTargetsInParallel": "1",
        "LastSwiftUpdateCheck": "1600",
        "LastUpgradeCheck": "1600",
        "TargetAttributes": {app_target: {"CreatedOnToolsVersion": "16.0"},
                             ext_target: {"CreatedOnToolsVersion": "16.0"}},
    },
    buildConfigurationList=config_list("project", project_debug, project_release),
    developmentRegion="en",
    hasScannedForEncodings="0",
    knownRegions=["en", "Base"],
    mainGroup=main_group,
    minimizedProjectReferenceProxies="1",
    preferredProjectObjectVersion="77",
    productRefGroup=products,
    projectDirPath='""',
    projectRoot='""',
    targets=[app_target, ext_target],
)

# --- Serialization (OpenStep plist, as Xcode writes it) -------------------------------------
SAFE = re.compile(r"^[A-Za-z0-9_$/:.]+$")


def q(value):
    if value.startswith('"') and value.endswith('"') and len(value) > 1:
        return value  # pre-quoted
    if SAFE.match(value) and value not in ("", ):
        return value
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'


def ser(value, indent):
    pad = "\t" * indent
    if isinstance(value, dict):
        inner = "".join(f"{pad}\t{q(k)} = {ser(v, indent + 1)};\n" for k, v in value.items())
        return "{\n" + inner + pad + "}"
    if isinstance(value, list):
        inner = "".join(f"{pad}\t{ser(v, indent + 1)},\n" for v in value)
        return "(\n" + inner + pad + ")"
    return q(str(value))


out = ["// !$*UTF8*$!\n{\n\tarchiveVersion = 1;\n\tclasses = {\n\t};\n\tobjectVersion = 77;\n\tobjects = {\n"]
for isa in sorted({o["isa"] for o in objects.values()}):
    out.append(f"\n/* Begin {isa} section */\n")
    for key in sorted(k for k, o in objects.items() if o["isa"] == isa):
        out.append(f"\t\t{key} = {ser(objects[key], 2)};\n")
    out.append(f"/* End {isa} section */\n")
out.append(f"\t}};\n\trootObject = {project_key};\n}}\n")
text = "".join(out)


# --- Self-check: parse it back with a strict OpenStep parser --------------------------------
def parse(s):
    i = 0

    def ws():
        nonlocal i
        while True:
            while i < len(s) and s[i] in " \t\n\r":
                i += 1
            if s.startswith("//", i):
                i = s.index("\n", i)
            elif s.startswith("/*", i):
                i = s.index("*/", i) + 2
            else:
                return

    def val():
        nonlocal i
        ws()
        c = s[i]
        if c == "{":
            i += 1
            d = {}
            while True:
                ws()
                if s[i] == "}":
                    i += 1
                    return d
                k = val()
                ws()
                assert s[i] == "=", f"expected = at {i}"
                i += 1
                d[k] = val()
                ws()
                assert s[i] == ";", f"expected ; at {i}: {s[i-40:i+10]!r}"
                i += 1
        if c == "(":
            i += 1
            arr = []
            while True:
                ws()
                if s[i] == ")":
                    i += 1
                    return arr
                arr.append(val())
                ws()
                assert s[i] == ",", f"expected , at {i}"
                i += 1
        if c == '"':
            j = i + 1
            while s[j] != '"':
                j += 2 if s[j] == "\\" else 1
            v = s[i + 1:j]
            i = j + 1
            return v
        m = re.compile(r"[A-Za-z0-9_$/:.\-]+").match(s, i)
        assert m, f"bad token at {i}: {s[i:i+20]!r}"
        i = m.end()
        return m.group(0)

    root = val()
    ws()
    assert i == len(s), "trailing content"
    return root


parsed = parse(text)
objs = parsed["objects"]
for key, o in objs.items():  # every referenced id must exist
    for v in o.values():
        refs = v if isinstance(v, list) else [v]
        for ref in refs:
            if isinstance(ref, str) and re.fullmatch(r"[0-9A-F]{24}", ref):
                assert ref in objs, f"{key} references missing {ref}"
assert parsed["rootObject"] in objs

proj_dir = os.path.join(ROOT, f"{APP}.xcodeproj")
os.makedirs(proj_dir, exist_ok=True)
with open(os.path.join(proj_dir, "project.pbxproj"), "w", encoding="utf-8") as fh:
    fh.write(text)
print(f"Wrote {proj_dir}/project.pbxproj ({len(objs)} objects, references verified)")
