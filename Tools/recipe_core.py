"""Ingredient catalog and recipe helpers shared by the recipe library generator.

Nutrition values are rough per-portion estimates for a ~3-year-old, as the ingredient is
typically used in one toddler serving of a recipe: (protein g, healthy fat g, complex carb g, iron mg).
"""

import re

CATALOG = {}
RECIPES = []

# GroceryCategory raw values
MEAT, SEA, DAIRY, PANTRY, SNACK, PRODUCE = (
    "poultryAndMeat", "seafood", "eggsAndDairy", "plantBasedPantry", "snacksAndBoosters", "produce")


def ing(key, name, cat, qty, nut, short=None, staple=False, note=None, hazard=None, allergens=(), swap=None, lf=False):
    assert key not in CATALOG, f"duplicate ingredient {key}"
    CATALOG[key] = {
        "key": key,
        "name": name,
        "shortName": short or name.lower(),
        "category": cat,
        "isProteinStaple": staple,
        "toddlerSafetyNote": note,
        "hazard": hazard,
        "allergens": list(allergens),
        "swapGroup": swap,
        "hasLactoseFreeOption": lf,
        "quantity": qty,
        "nutrition": {
            "proteinGrams": float(nut[0]),
            "healthyFatGrams": float(nut[1]),
            "complexCarbGrams": float(nut[2]),
            "ironMilligrams": float(nut[3]),
        },
    }


# --- Poultry & Meat -------------------------------------------------------------------------
ing("chickenBreast", "Boneless skinless chicken breast/tenders", MEAT, "1 lb", (9, 1, 0, 0.3), "chicken breast", True,
    "Pound thin or shred; avoid dry cubes.", "toughMeat", swap="poultry")
ing("chickenThighs", "Skinless chicken thighs", MEAT, "1.5 lb", (8, 3, 0, 0.5), "chicken thighs", True,
    "Best for tender toddler shredding.", swap="poultry")
ing("deliTurkey", "Low-sodium sliced turkey or chicken", MEAT, "6 oz", (5, 1, 1, 0.3), "sliced turkey", True,
    hazard="toughMeat", swap="poultry")
ing("groundTurkey", "Lean ground turkey (93/7)", MEAT, "1 lb", (8, 3, 0, 0.6), "ground turkey", True,
    "Break into fine crumbles.", swap="groundMeat")
ing("groundBeef", "Lean ground beef (90/10)", MEAT, "1 lb", (8, 4, 0, 1.2), "ground beef", True,
    "Break into fine crumbles. Great iron source.", swap="groundMeat")
ing("groundChicken", "Ground chicken", MEAT, "1 lb", (8, 2, 0, 0.4), "ground chicken", True, swap="groundMeat")
ing("groundPork", "Lean ground pork", MEAT, "1 lb", (7, 4, 0, 0.4), "ground pork", True, swap="groundMeat")
ing("groundLamb", "Ground lamb", MEAT, "1 lb", (7, 5, 0, 0.8), "ground lamb", True, swap="groundMeat")
ing("beefChuck", "Beef chuck (for stew or pot roast)", MEAT, "1.5 lb", (9, 4, 0, 1.3), "beef chuck", True,
    "Braise until fork-tender, then shred.", "toughMeat", swap="roast")
ing("porkShoulder", "Pork shoulder (for pulled pork)", MEAT, "2 lb", (8, 5, 0, 0.5), "pork shoulder", True,
    "Slow-cook until it pulls apart easily.", "toughMeat", swap="roast")
ing("porkTenderloin", "Pork tenderloin", MEAT, "1 lb", (9, 1, 0, 0.4), "pork tenderloin", True,
    "Slice thin across the grain.", "toughMeat", swap="roast")
ing("ham", "Low-sodium ham", MEAT, "6 oz", (5, 1, 1, 0.3), "ham", True,
    "Dice small; it's salty, so keep portions small.", "toughMeat")
ing("chickenSausage", "Mild chicken sausage", MEAT, "12 oz", (6, 4, 1, 0.4), "chicken sausage", True,
    hazard="sausage")

# --- Seafood --------------------------------------------------------------------------------
ing("salmon", "Salmon fillets", SEA, "2 fillets", (8, 4, 0, 0.3), "salmon", True, "Omega-3 rich.",
    "fishBones", ["fish"], "fish")
ing("whiteFish", "White fish fillets (cod, tilapia, snapper)", SEA, "12 oz", (7, 0.5, 0, 0.2), "white fish", True,
    hazard="fishBones", allergens=["fish"], swap="fish")
ing("cannedTuna", "Canned tuna/salmon in water", SEA, "2 cans", (7, 0.5, 0, 0.4), "canned tuna", True,
    "Choose light tuna; limit to 1–2 toddler servings a week.", allergens=["fish"], swap="fish")
ing("shrimp", "Shrimp (peeled, deveined)", SEA, "12 oz", (6, 0.3, 0, 0.1), "shrimp", True,
    "Chop into small pieces.", "toughMeat", ["shellfish"], "fish")
ing("sardines", "Canned sardines (boneless, in water)", SEA, "1 can", (6, 3, 0, 0.8), "sardines", True,
    "Mash well. Rich in iron and omega-3s.", allergens=["fish"], swap="fish")

# --- Eggs & Dairy ---------------------------------------------------------------------------
ing("eggs", "Whole eggs & liquid egg whites", DAIRY, "1 dozen", (6, 5, 0.5, 0.9), "eggs", True, allergens=["egg"])
ing("greekYogurt", "Plain Greek yogurt", DAIRY, "32 oz tub", (8, 2, 4, 0.1), "Greek yogurt", True,
    allergens=["dairy"], swap="dairyProtein", lf=True)
ing("cottageCheese", "Cottage cheese", DAIRY, "16 oz", (10, 2, 3, 0.1), "cottage cheese", True,
    allergens=["dairy"], swap="dairyProtein", lf=True)
ing("hardCheese", "Hard cheeses (aged cheddar, parmesan)", DAIRY, "8 oz each", (4, 5, 0, 0.1), "cheddar", True,
    hazard="firmCubes", allergens=["dairy"], swap="cheese")
ing("mozzarella", "Shredded mozzarella", DAIRY, "8 oz", (4, 3, 0.5, 0.1), "mozzarella", True,
    allergens=["dairy"], swap="cheese")
ing("ricotta", "Whole-milk ricotta", DAIRY, "15 oz", (5, 5, 2, 0.2), "ricotta", True,
    allergens=["dairy"], swap="dairyProtein")
ing("feta", "Crumbled feta", DAIRY, "4 oz", (2, 3, 0.5, 0.1), "feta", allergens=["dairy"], swap="cheese")
ing("creamCheese", "Cream cheese", DAIRY, "8 oz", (1, 4, 1, 0), "cream cheese", allergens=["dairy"])
ing("kefir", "Plain kefir", DAIRY, "32 oz", (5, 3, 6, 0), "kefir", True, allergens=["dairy"], lf=True)
ing("milk", "Whole milk", DAIRY, "½ gallon", (4, 4, 6, 0), "milk", allergens=["dairy"], lf=True)
ing("butter", "Unsalted butter", DAIRY, "1 stick", (0, 3, 0, 0), "butter", allergens=["dairy"])

# --- Plant-Based & Pantry -------------------------------------------------------------------
ing("beans", "Canned black beans/kidney beans/chickpeas", PANTRY, "3 cans", (4, 0.3, 10, 1.0), "beans", True,
    "Rinse well to cut sodium.", swap="plantProtein")
ing("whiteBeans", "Canned white beans (cannellini)", PANTRY, "2 cans", (4, 0.3, 10, 1.2), "white beans", True,
    "Rinse well to cut sodium.", swap="plantProtein")
ing("lentils", "Dry red/brown lentils", PANTRY, "1 lb bag", (5, 0.2, 10, 1.6), "lentils", True,
    "Red lentils cook soft in 15–20 min, no soaking.", swap="plantProtein")
ing("splitPeas", "Dry green split peas", PANTRY, "1 lb bag", (5, 0.2, 12, 0.8), "split peas", True, swap="plantProtein")
ing("tofu", "Firm/extra-firm tofu", PANTRY, "1 block", (5, 3, 1, 1.0), "tofu", True,
    allergens=["soy"], swap="plantProtein")
ing("edamame", "Frozen shelled edamame", PANTRY, "1 bag", (4, 2, 3, 0.8), "edamame", True,
    hazard="roundFood", allergens=["soy"], swap="plantProtein")
ing("refriedBeans", "Canned refried beans (low-sodium)", PANTRY, "1 can", (3, 1, 8, 0.8), "refried beans", True,
    swap="plantProtein")
ing("hummus", "Plain hummus", PANTRY, "10 oz", (2, 4, 4, 0.6), "hummus", True, "Contains tahini (sesame).",
    allergens=["sesame"])
ing("bread", "Whole-wheat bread", PANTRY, "1 loaf", (3, 1, 12, 0.8), "whole-wheat bread", allergens=["wheat"])
ing("oats", "Rolled oats", PANTRY, "1 canister", (2, 1, 10, 0.8), "oats")
ing("crackers", "Whole-grain crackers", PANTRY, "1 box", (1, 2, 8, 0.4), "crackers", allergens=["wheat"])
ing("tortillas", "Small whole-wheat tortillas", PANTRY, "1 pack", (2, 2, 12, 0.6), "tortilla", allergens=["wheat"])
ing("pasta", "Pasta (rotini, penne, shells)", PANTRY, "1 lb", (3, 0.5, 18, 0.8), "pasta", allergens=["wheat"])
ing("rice", "Brown or white rice", PANTRY, "2 cups dry", (1.5, 0.2, 15, 0.2), "rice")
ing("pita", "Soft whole-wheat pita", PANTRY, "1 pack", (2, 0.5, 11, 0.6), "pita", allergens=["wheat"])
ing("panko", "Whole-wheat panko breadcrumbs", PANTRY, "1 box", (1, 0.3, 5, 0.3), "panko", allergens=["wheat"])
ing("quinoa", "Quinoa", PANTRY, "1 lb", (2, 0.7, 10, 0.7), "quinoa")
ing("couscous", "Whole-wheat couscous", PANTRY, "1 box", (2, 0.2, 12, 0.3), "couscous", allergens=["wheat"])
ing("orzo", "Orzo", PANTRY, "1 lb", (3, 0.3, 16, 0.7), "orzo", allergens=["wheat"])
ing("eggNoodles", "Egg noodles", PANTRY, "12 oz", (3, 1, 16, 0.8), "egg noodles", allergens=["wheat", "egg"])
ing("flour", "Whole-wheat flour", PANTRY, "2 lb", (2, 0.3, 10, 0.5), "flour", allergens=["wheat"])
ing("polenta", "Polenta (cornmeal)", PANTRY, "1 lb", (1, 0.2, 12, 0.4), "polenta")
ing("englishMuffins", "Whole-wheat English muffins", PANTRY, "1 pack", (3, 0.5, 13, 0.9), "English muffin",
    allergens=["wheat"])
ing("riceCakes", "Plain rice cakes", PANTRY, "1 pack", (0.5, 0.2, 7, 0.1), "rice cakes")
ing("tomatoes", "Crushed tomatoes / passata", PANTRY, "2 jars", (1, 0, 4, 0.5), "crushed tomatoes")
ing("marinara", "Low-sodium marinara sauce", PANTRY, "1 jar", (1, 1, 4, 0.4), "marinara")
ing("broth", "Low-sodium chicken or veggie broth", PANTRY, "32 oz", (1, 0, 0.5, 0.1), "low-sodium broth")
ing("coconutMilk", "Light coconut milk", PANTRY, "1 can", (0.5, 4, 1, 0.5), "coconut milk")
ing("oliveOil", "Olive oil", PANTRY, "1 bottle", (0, 4.5, 0, 0), "olive oil")
ing("soySauce", "Low-sodium soy sauce", PANTRY, "1 bottle", (0.5, 0, 0.5, 0.1), "low-sodium soy sauce",
    allergens=["soy", "wheat"])
ing("spices", "Mild spices (cumin, paprika, oregano)", PANTRY, "1 jar each", (0, 0, 0.2, 0.2), "mild spices")
ing("curryPowder", "Mild curry powder", PANTRY, "1 jar", (0, 0, 0.3, 0.3), "mild curry powder")
ing("cinnamon", "Ground cinnamon", PANTRY, "1 jar", (0, 0, 0.3, 0.1), "cinnamon")
ing("vanilla", "Vanilla extract", PANTRY, "1 bottle", (0, 0, 0, 0), "vanilla")
ing("cocoa", "Unsweetened cocoa powder", PANTRY, "1 tin", (0.5, 0.3, 1.5, 0.4), "cocoa")
ing("bakingPowder", "Baking powder", PANTRY, "1 tin", (0, 0, 0, 0), "baking powder")
ing("honey", "Honey", PANTRY, "1 jar", (0, 0, 6, 0), "honey", hazard="honey")
ing("mapleSyrup", "Pure maple syrup", PANTRY, "1 bottle", (0, 0, 5, 0), "maple syrup")
ing("chiaSeeds", "Chia seeds", PANTRY, "1 bag", (1, 2, 3, 0.4), "chia seeds", note="Always soak; never serve dry.")
ing("flaxseed", "Ground flaxseed", PANTRY, "1 bag", (1, 2, 1, 0.3), "ground flaxseed")
ing("shreddedCoconut", "Unsweetened shredded coconut", PANTRY, "1 bag", (0.3, 3, 1, 0.2), "shredded coconut")
ing("pumpkinPuree", "Canned pumpkin purée", PANTRY, "1 can", (0.5, 0, 4, 0.6), "pumpkin purée")
ing("appleSauce", "Unsweetened applesauce", PANTRY, "1 jar", (0, 0, 6, 0.1), "applesauce")
ing("raisins", "Raisins", PANTRY, "1 box", (0.3, 0, 8, 0.2), "raisins", note="Chop finely or plump in warm water.",
    hazard="driedFruit")
ing("dates", "Pitted Medjool dates", PANTRY, "1 box", (0.3, 0, 9, 0.2), "dates", note="Blend or chop finely.",
    hazard="driedFruit")
ing("salsa", "Mild salsa", PANTRY, "1 jar", (0.2, 0, 1, 0.1), "mild salsa")

# --- Quick Snacks & Boosters ----------------------------------------------------------------
ing("nutButter", "Natural peanut/almond butter", SNACK, "1 jar", (4, 8, 3, 0.3), "peanut butter", True,
    "Safety rule: Thin smear only.", "nutButter", ["peanut", "treeNut"], "spread")
ing("seedButter", "Sunflower seed butter (nut-free)", SNACK, "1 jar", (3, 8, 3, 0.6), "sunflower seed butter", True,
    "Nut-free swap. Thin smear only.", "nutButter", swap="spread")
ing("tahini", "Tahini", SNACK, "1 jar", (2, 5, 1, 0.6), "tahini", True, "Thin smear only.", "nutButter",
    ["sesame"], "spread")
ing("rawNuts", "Raw almonds/walnuts/pumpkin seeds", SNACK, "1 bag", (3, 7, 2, 0.4), "finely ground nuts", True,
    "Safety rule: Blend or crush for 3-year-olds.", "wholeNuts", ["treeNut"])
ing("hempSeeds", "Hemp seeds", SNACK, "1 bag", (3, 5, 1, 0.8), "hemp seeds", True)
ing("proteinPowder", "Protein powder (unflavored)", SNACK, "1 tub", (10, 1, 2, 0.2), "protein powder", True,
    "Check with your pediatrician before using for toddlers.", allergens=["dairy"])

# --- Produce --------------------------------------------------------------------------------
ing("banana", "Ripe bananas", PRODUCE, "1 bunch", (0.5, 0, 14, 0.2), "banana")
ing("berries", "Mixed berries (strawberries, blueberries, raspberries)", PRODUCE, "3 pints", (0.5, 0.2, 7, 0.2),
    "berries", note="Quarter strawberries; smash blueberries.", hazard="roundFood")
ing("strawberries", "Strawberries", PRODUCE, "1 lb", (0.4, 0.2, 5, 0.3), "strawberries", note="Hull and quarter.")
ing("blueberries", "Blueberries", PRODUCE, "1 pint", (0.4, 0.2, 7, 0.2), "blueberries", note="Halve or smash.",
    hazard="roundFood")
ing("applesPears", "Apples or pears", PRODUCE, "4", (0.2, 0.1, 12, 0.1), "apple", hazard="hardRawProduce")
ing("mangoPeach", "Ripe mango or peaches", PRODUCE, "2", (0.5, 0.2, 10, 0.1), "mango")
ing("pineappleMelon", "Pineapple or melon", PRODUCE, "1", (0.5, 0.1, 8, 0.2), "melon")
ing("kiwi", "Kiwi", PRODUCE, "4", (0.5, 0.2, 7, 0.2), "kiwi")
ing("grapes", "Grapes", PRODUCE, "1 lb", (0.3, 0.1, 8, 0.2), "grapes", note="Slice lengthwise into quarters.",
    hazard="roundFood")
ing("cherryTomatoes", "Cherry tomatoes", PRODUCE, "1 pint", (0.3, 0.1, 2, 0.1), "cherry tomatoes",
    note="Slice lengthwise into quarters.", hazard="roundFood")
ing("mandarin", "Mandarin oranges", PRODUCE, "1 bag", (0.4, 0.1, 6, 0.1), "mandarin")
ing("lemon", "Lemons", PRODUCE, "2", (0, 0, 1, 0), "lemon")
ing("avocado", "Avocados", PRODUCE, "3", (1, 7, 3, 0.3), "avocado")
ing("cucumber", "Cucumber", PRODUCE, "1", (0.3, 0, 1, 0.1), "cucumber", hazard="hardRawProduce")
ing("sweetPotato", "Sweet potatoes", PRODUCE, "2", (1, 0, 12, 0.4), "sweet potato")
ing("potatoes", "Yukon gold potatoes", PRODUCE, "1.5 lb", (1.5, 0, 13, 0.4), "potatoes")
ing("broccoli", "Broccoli", PRODUCE, "1 head", (1, 0.2, 2, 0.3), "broccoli")
ing("cauliflower", "Cauliflower", PRODUCE, "1 head", (1, 0.1, 2, 0.2), "cauliflower")
ing("peas", "Frozen green peas", PRODUCE, "1 bag", (2, 0.2, 5, 0.6), "peas")
ing("corn", "Frozen sweet corn", PRODUCE, "1 bag", (1, 0.5, 6, 0.2), "sweet corn")
ing("greenBeans", "Green beans", PRODUCE, "12 oz", (0.5, 0, 2, 0.3), "green beans")
ing("bellPepper", "Bell peppers", PRODUCE, "2", (0.3, 0, 2, 0.1), "bell pepper", hazard="hardRawProduce")
ing("carrots", "Carrots", PRODUCE, "1 lb", (0.3, 0, 3, 0.1), "carrot", hazard="hardRawProduce")
ing("zucchini", "Zucchini", PRODUCE, "2", (0.5, 0.1, 1.5, 0.2), "zucchini")
ing("butternutSquash", "Butternut squash", PRODUCE, "1", (0.5, 0, 6, 0.4), "butternut squash")
ing("spinach", "Baby spinach", PRODUCE, "5 oz", (0.5, 0, 0.5, 0.8), "spinach")
ing("kale", "Kale", PRODUCE, "1 bunch", (0.5, 0.2, 1, 0.4), "kale", note="Chop finely and cook until soft.")
ing("mushrooms", "Mushrooms", PRODUCE, "8 oz", (1, 0.1, 1, 0.2), "mushrooms")
ing("onion", "Yellow onions", PRODUCE, "2", (0.2, 0, 2, 0.1), "onion")
ing("garlic", "Garlic", PRODUCE, "1 head", (0, 0, 0.3, 0), "garlic")
ing("ginger", "Fresh ginger", PRODUCE, "1 knob", (0, 0, 0.2, 0), "ginger")
ing("herbs", "Fresh herbs (basil, dill, parsley)", PRODUCE, "1 bunch", (0, 0, 0, 0.1), "fresh herbs")
ing("beets", "Cooked beets", PRODUCE, "1 pack", (0.5, 0, 4, 0.4), "beets")
ing("plantain", "Ripe sweet plantains", PRODUCE, "2", (0.5, 0.1, 16, 0.3), "plantain")
ing("frozenVeg", "Frozen mixed vegetables", PRODUCE, "1 bag", (1, 0.1, 4, 0.4), "mixed vegetables")


# --- Recipe helpers -------------------------------------------------------------------------

SLOT_CODES = {
    "B": ["breakfast"],
    "S": ["morningSnack", "afternoonSnack"],
    "L": ["lunch"],
    "D": ["dinner"],
}
TEXTURE_CODES = {
    "soft": "softScoopable",
    "finger": "fingerFood",
    "dip": "dippers",
    "smooth": "smoothies",
    "crispy": "crispy",
}
SEASONINGS = {"spices", "curryPowder", "cinnamon", "vanilla", "bakingPowder", "garlic", "ginger", "herbs", "lemon",
              "oliveOil", "soySauce", "broth"}


def slugify(text):
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")


def short(key):
    return CATALOG[key]["shortName"]


def join(keys, skip_seasonings=False):
    names = [short(k) for k in keys if not (skip_seasonings and k in SEASONINGS)]
    if not names:
        return ""
    if len(names) == 1:
        return names[0]
    return ", ".join(names[:-1]) + " and " + names[-1]


def macros_for(keys):
    total = [0.0, 0.0, 0.0, 0.0]
    for k in keys:
        n = CATALOG[k]["nutrition"]
        total[0] += n["proteinGrams"]
        total[1] += n["healthyFatGrams"]
        total[2] += n["complexCarbGrams"]
        total[3] += n["ironMilligrams"]
    return {
        "proteinGrams": round(total[0]),
        "healthyFatGrams": round(total[1]),
        "complexCarbGrams": round(total[2]),
        "ironMilligrams": round(total[3], 1),
    }


def r(slots, title, mins, keys, textures, steps, cuisine="American", batch=False, macros=None, plan_only=False,
      rid=None):
    """Registers a recipe. `slots` is a string of codes like "B", "S", "LD", "BS"."""
    slot_list = []
    for code in slots:
        for s in SLOT_CODES[code]:
            if s not in slot_list:
                slot_list.append(s)
    keys = list(dict.fromkeys(keys))  # de-duplicate, keep order
    for k in keys:
        assert k in CATALOG, f"{title}: unknown ingredient '{k}'"
    RECIPES.append({
        "id": rid or slugify(title),
        "title": title,
        "slots": slot_list,
        "prepTimeMinutes": int(mins),
        "ingredientKeys": keys,
        "textures": [TEXTURE_CODES[t] for t in textures.split()],
        "macros": macros or macros_for(keys),
        "steps": steps,
        "cuisine": cuisine,
        "batchFriendly": batch,
        "planOnly": plan_only,
    })
