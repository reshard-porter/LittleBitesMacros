#!/usr/bin/env python3
"""Draws the LittleBites app icon (light, dark and tinted variants) into
LittleBitesMacros/Assets.xcassets/AppIcon.appiconset.

Usage:  python3 Tools/make_app_icon.py      (requires Pillow)
"""

import json
import os

from PIL import Image, ImageChops, ImageDraw, ImageFilter

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
CATALOG = os.path.join(ROOT, "LittleBitesMacros", "Assets.xcassets")
ICONSET = os.path.join(CATALOG, "AppIcon.appiconset")

SIZE = 1024
SCALE = 4  # supersample for smooth edges
S = SIZE * SCALE

SAGE_TOP, SAGE_BOTTOM = (98, 146, 111), (62, 110, 77)
CREAM, CREAM_SHADE = (250, 248, 245), (232, 226, 214)
APRICOT, APRICOT_LIGHT = (244, 162, 97), (250, 196, 140)
LEAF, LEAF_DARK = (122, 176, 106), (74, 124, 89)


def u(v):
    """Design units (0–1024) → supersampled pixels."""
    return int(v * SCALE)


def gradient(top, bottom):
    img = Image.new("RGB", (S, S))
    draw = ImageDraw.Draw(img)
    for y in range(S):
        t = y / (S - 1)
        draw.line([(0, y), (S, y)], fill=tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
    return img


def leaf_mask(cx, cy, length, width, angle):
    """A pointed leaf shape (intersection of two circles), rotated."""
    m = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(m)
    r = (length ** 2 / 4 + width ** 2 / 4) / width  # radius giving the requested lens size
    off = r - width / 2
    a = Image.new("L", (S, S), 0)
    b = Image.new("L", (S, S), 0)
    ImageDraw.Draw(a).ellipse([cx - r, cy - off - r, cx + r, cy - off + r], fill=255)
    ImageDraw.Draw(b).ellipse([cx - r, cy + off - r, cx + r, cy + off + r], fill=255)
    m = ImageChops.multiply(a, b)
    return m.rotate(angle, center=(cx, cy), resample=Image.BICUBIC)


def foreground(palette):
    """Returns an RGBA layer with the bowl, peach and leaf."""
    layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)

    # Peach / sun rising out of the bowl
    peach_c, peach_r = (u(512), u(470)), u(205)
    d.ellipse([peach_c[0] - peach_r, peach_c[1] - peach_r, peach_c[0] + peach_r, peach_c[1] + peach_r],
              fill=palette["apricot"])
    hl_r = u(70)
    d.ellipse([u(420) - hl_r, u(380) - hl_r, u(420) + hl_r, u(380) + hl_r], fill=palette["apricot_light"])

    # Stem + leaf on top of the peach
    d.rounded_rectangle([u(500), u(232), u(526), u(300)], radius=u(13), fill=palette["leaf_dark"])
    leaf = leaf_mask(u(590), u(240), u(190), u(92), 28)
    layer.paste(Image.new("RGBA", (S, S), palette["leaf"]), (0, 0), leaf)
    vein = Image.new("L", (S, S), 0)
    ImageDraw.Draw(vein).line([(u(510), u(262)), (u(668), u(212))], fill=255, width=u(9))
    vein = ImageChops.multiply(vein, leaf)
    layer.paste(Image.new("RGBA", (S, S), palette["leaf_dark"]), (0, 0), vein)

    # Bowl (drawn last so it hides the bottom of the peach)
    bowl = Image.new("L", (S, S), 0)
    bd = ImageDraw.Draw(bowl)
    bd.pieslice([u(196), u(330), u(828), u(900)], 0, 180, fill=255)   # deep half-bowl
    bd.rectangle([u(196), u(605), u(828), u(615)], fill=255)          # close the seam
    layer.paste(Image.new("RGBA", (S, S), palette["cream"]), (0, 0), bowl)

    # Rim band and a soft shade line for depth
    d.rounded_rectangle([u(170), u(574), u(854), u(640)], radius=u(33), fill=palette["cream"])
    d.rounded_rectangle([u(240), u(660), u(784), u(684)], radius=u(12), fill=palette["shade"])

    # Foot of the bowl
    d.rounded_rectangle([u(420), u(870), u(604), u(912)], radius=u(21), fill=palette["shade"])
    return layer


def shadow(layer, opacity):
    alpha = layer.split()[3].filter(ImageFilter.GaussianBlur(u(18)))
    alpha = alpha.point(lambda a: int(a * opacity))
    s = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    s.putalpha(alpha)
    return ImageChops.offset(s, 0, u(14))


def finish(img, mode):
    return img.resize((SIZE, SIZE), Image.LANCZOS).convert(mode)


light_palette = dict(apricot=APRICOT, apricot_light=APRICOT_LIGHT, leaf=LEAF, leaf_dark=LEAF_DARK,
                     cream=CREAM, shade=CREAM_SHADE)
dark_palette = dict(apricot=(246, 170, 108), apricot_light=(250, 200, 150), leaf=(134, 190, 118),
                    leaf_dark=(96, 150, 108), cream=(236, 232, 224), shade=(196, 190, 178))

# Light: opaque sage gradient (App Store icons must not have transparency)
fg = foreground(light_palette)
light = gradient(SAGE_TOP, SAGE_BOTTOM).convert("RGBA")
light = Image.alpha_composite(light, shadow(fg, 0.28))
light = Image.alpha_composite(light, fg)

# Dark: transparent background so iOS supplies its dark backdrop
dark_fg = foreground(dark_palette)
dark = Image.alpha_composite(shadow(dark_fg, 0.35), dark_fg)

# Tinted: grayscale artwork on black; iOS applies the user's tint
gray = foreground(light_palette).convert("LA").convert("RGBA")
tinted = Image.alpha_composite(Image.new("RGBA", (S, S), (0, 0, 0, 255)), gray)

os.makedirs(ICONSET, exist_ok=True)
finish(light, "RGB").save(os.path.join(ICONSET, "AppIcon.png"), optimize=True)
finish(dark, "RGBA").save(os.path.join(ICONSET, "AppIcon-Dark.png"), optimize=True)
finish(tinted, "RGB").save(os.path.join(ICONSET, "AppIcon-Tinted.png"), optimize=True)

with open(os.path.join(CATALOG, "Contents.json"), "w") as fh:
    json.dump({"info": {"author": "xcode", "version": 1}}, fh, indent=2)
with open(os.path.join(ICONSET, "Contents.json"), "w") as fh:
    json.dump({
        "images": [
            {"filename": "AppIcon.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"},
            {"appearances": [{"appearance": "luminosity", "value": "dark"}],
             "filename": "AppIcon-Dark.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"},
            {"appearances": [{"appearance": "luminosity", "value": "tinted"}],
             "filename": "AppIcon-Tinted.png", "idiom": "universal", "platform": "ios", "size": "1024x1024"},
        ],
        "info": {"author": "xcode", "version": 1},
    }, fh, indent=2)

print(f"Wrote {ICONSET}")
