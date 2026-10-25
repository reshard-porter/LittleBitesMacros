#!/usr/bin/env python3
"""Generates LittleBitesMacros/RecipeLibrary.json: the ingredient catalog, 400+ toddler recipes,
and the default 5-day plan.

Usage:  python3 Tools/generate_recipes.py
"""

import json
import os
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from recipe_core import CATALOG, RECIPES, r  # noqa: E402
import recipes_breakfast_snacks  # noqa: E402,F401
import recipes_lunch_dinner  # noqa: E402,F401


def m(p, f, c, fe):
    return {"proteinGrams": p, "healthyFatGrams": f, "complexCarbGrams": c, "ironMilligrams": fe}


# --- Signature recipes used by the default 5-day plan (hand-tuned macros) ---------------------
SEED = [
    (1, "breakfast", "B", "Soft Scrambled Eggs, Toast Strips & Banana", 10, ["eggs", "hardCheese", "milk", "bread", "banana"], "soft finger", m(12, 11, 22, 1.6),
     ["Whisk 1–2 eggs with a splash of milk; cook low and slow until soft curds form.", "Fold in 1 tbsp shredded cheddar off the heat.", "Toast 1 slice whole-wheat bread and cut into 3–4 finger strips.", "Dice ripe banana into soft ½-inch pieces."], False),
    (1, "morningSnack", "S", "Greek Yogurt with Mashed Berries, Honey & Cinnamon", 3, ["greekYogurt", "berries", "honey", "cinnamon"], "soft", m(9, 3, 14, 0.3),
     ["Spoon ½ cup plain Greek yogurt into a bowl.", "Mash a small handful of berries with a fork and swirl them in.", "Drizzle ½ tsp honey (12 months+ only) and dust with cinnamon."], False),
    (1, "lunch", "L", "Turkey & Cheese Roll-Ups, Edamame & Cucumber Sticks", 8, ["deliTurkey", "hardCheese", "edamame", "cucumber"], "finger", m(16, 8, 8, 1.5),
     ["Lay a slice of low-sodium turkey or chicken flat, top with a thin slice of cheese, and roll tightly.", "Slice roll-ups into ½-inch pinwheels.", "Steam ¼ cup shelled edamame 4–5 min until very soft, then lightly smash.", "Peel the cucumber and cut into thin sticks."], False),
    (1, "afternoonSnack", "S", "Thin Apple/Pear Slices with Peanut Butter", 4, ["applesPears", "nutButter"], "finger dip", m(4, 8, 14, 0.4),
     ["Peel and core; slice into very thin wedges (steam 2 min for extra softness).", "Spread a thin smear of natural peanut butter on each slice."], False),
    (1, "dinner", "D", "Baked Flaky Salmon, Mashed Sweet Potato & Soft Broccoli", 25, ["salmon", "sweetPotato", "broccoli", "butter"], "soft finger", m(18, 12, 22, 1.2),
     ["Bake salmon at 400°F / 200°C for 12–15 min until it flakes easily.", "Flake into small pieces and check carefully for pin bones.", "Mash roasted sweet potato with a little butter.", "Steam broccoli florets 5–6 min until fork-tender; cut into small trees."], False),
    (2, "breakfast", "B", "Warm Nut-Butter Oatmeal with Diced Mango", 8, ["oats", "milk", "nutButter", "mangoPeach"], "soft", m(10, 10, 30, 2.0),
     ["Simmer ⅓ cup oats in ⅔ cup milk for 5 min until creamy.", "Stir in 1 tsp nut butter until fully melted in (no clumps).", "Top with soft diced mango or peach; cool to warm."], False),
    (2, "morningSnack", "S", "Cottage Cheese with Soft Pineapple or Melon", 3, ["cottageCheese", "pineappleMelon"], "soft", m(12, 3, 10, 0.2),
     ["Spoon ⅓ cup cottage cheese into a bowl.", "Dice ripe pineapple or melon into small, soft pieces and fold in."], False),
    (2, "lunch", "L", "Black Bean & Cheese Quesadilla Triangles with Avocado", 10, ["beans", "hardCheese", "tortillas", "avocado"], "finger crispy", m(12, 13, 26, 2.2),
     ["Mash ¼ cup rinsed black beans with a fork.", "Spread on half a tortilla, sprinkle with cheese, fold, and toast 2–3 min per side.", "Cool slightly; cut into small triangles.", "Serve with diced ripe avocado."], False),
    (2, "afternoonSnack", "S", "Sliced Hard-Boiled Egg with Whole-Grain Crackers", 2, ["eggs", "crackers"], "finger", m(7, 6, 10, 1.0),
     ["Peel a hard-boiled egg from batch prep.", "Slice into thin rounds or chop finely.", "Serve with 3–4 whole-grain crackers."], False),
    (2, "dinner", "D", "Mild Turkey Bolognese with Rotini & Peas", 30, ["groundTurkey", "tomatoes", "carrots", "pasta", "hardCheese", "peas"], "soft", m(20, 10, 32, 2.8),
     ["Brown 1 lb lean ground turkey, breaking it into very fine crumbles.", "Simmer with passata and finely grated carrot for 15 min; skip added salt.", "Cook rotini slightly past al dente for easy chewing.", "Toss with sauce, top with grated parmesan, and serve with soft-steamed peas.", "Cook once, serve twice: refrigerate half the pasta and sauce for Day 3 lunch."], False),
    (3, "breakfast", "B", "Greek Yogurt Parfait with Soft Oats & Strawberries", 5, ["greekYogurt", "oats", "milk", "berries"], "soft", m(11, 3, 22, 1.0),
     ["Soak 2 tbsp oats in a splash of milk for 5 min (or overnight) until soft.", "Layer with Greek yogurt.", "Top with hulled, quartered strawberries."], False),
    (3, "morningSnack", "S", "Small Cheddar Cubes & Quartered Grapes", 4, ["hardCheese", "grapes"], "finger", m(7, 9, 10, 0.2),
     ["Cut aged cheddar into small cubes or thin sticks.", "Slice grapes lengthwise into quarters."], False),
    (3, "lunch", "L", "Leftover Turkey Bolognese with Soft Bell Pepper Strips", 5, ["groundTurkey", "tomatoes", "pasta", "hardCheese", "bellPepper"], "soft finger", m(19, 9, 30, 2.8),
     ["Reheat Day 2 Bolognese until steaming (165°F / 74°C), then cool to warm.", "Steam bell pepper strips 4 min until soft and bendable."], True),
    (3, "afternoonSnack", "S", "Mashed Chickpea Hummus with Soft Pita Triangles", 5, ["beans", "pita"], "dip", m(5, 5, 18, 1.3),
     ["Blend rinsed chickpeas with olive oil, lemon, and a splash of water until very smooth.", "Warm pita and cut into small triangles for dipping."], False),
    (3, "dinner", "D", "Braised Shredded Chicken Thighs, Rice, Beans & Plantain", 45, ["chickenThighs", "rice", "beans", "plantain", "carrots"], "soft finger", m(20, 10, 30, 2.4),
     ["Braise 1.5 lb skinless thighs in low-sodium broth with garlic and cumin for 35–40 min.", "Shred with two forks into thin strands.", "Serve with rice, lightly mashed black beans, and soft roasted plantain or steamed carrot half-moons.", "Cook once, serve twice: set aside 1 cup chicken, rice, and beans for Day 5 lunch."], False),
    (4, "breakfast", "B", "3-Ingredient Banana Egg Pancakes with Yogurt Dip", 12, ["banana", "eggs", "oats", "greekYogurt"], "finger dip", m(15, 9, 26, 1.6),
     ["Blend 1 ripe banana, 2 eggs, and 2 tbsp rolled oats until smooth.", "Cook silver-dollar pancakes over medium-low, 1–2 min per side.", "Cut into strips and serve with a Greek yogurt dip."], False),
    (4, "morningSnack", "S", "Steamed Edamame & Mandarin Segments", 6, ["edamame", "mandarin"], "finger", m(6, 3, 10, 1.2),
     ["Steam shelled edamame until very soft; halve or smash.", "Peel mandarin segments and cut each in half."], False),
    (4, "lunch", "L", "Mild Tuna Salad Bread Fingers with Cherry Tomatoes", 8, ["cannedTuna", "greekYogurt", "bread", "cherryTomatoes"], "finger", m(16, 5, 20, 1.6),
     ["Mix drained tuna with a spoon of Greek yogurt (or mayo) until creamy.", "Spread on bread and cut into fingers.", "Slice cherry tomatoes lengthwise into quarters."], False),
    (4, "afternoonSnack", "S", "Green Protein Smoothie", 4, ["milk", "greekYogurt", "spinach", "banana", "nutButter"], "smooth", m(14, 9, 24, 1.1),
     ["Blend ½ cup milk, ¼ cup Greek yogurt, a handful of baby spinach, ½ banana, and 1 tsp peanut butter.", "Blend until completely smooth; serve in an open or straw cup."], False),
    (4, "dinner", "D", "Thick Red Lentil & Vegetable Stew with Buttered Toast", 30, ["lentils", "carrots", "tomatoes", "bread", "butter"], "soft dip", m(13, 8, 34, 3.4),
     ["Simmer 1 cup rinsed red lentils with diced carrot and crushed tomatoes for 20 min until thick and soft.", "Mash lightly for a smoother texture.", "Serve warm with buttered toast strips for dipping."], False),
    (5, "breakfast", "B", "Avocado Toast Fingers, Cheesy Eggs & Blueberries", 10, ["bread", "avocado", "hempSeeds", "eggs", "hardCheese", "berries"], "finger", m(16, 18, 22, 2.2),
     ["Mash avocado onto toast; sprinkle with hemp seeds and cut into fingers.", "Soft-scramble eggs with a little cheddar.", "Halve or smash blueberries."], False),
    (5, "morningSnack", "S", "Cottage Cheese with Banana & Cinnamon", 3, ["cottageCheese", "banana", "cinnamon"], "soft", m(11, 2, 16, 0.2),
     ["Top ⅓ cup cottage cheese (or Greek yogurt) with sliced banana and a pinch of cinnamon."], False),
    (5, "lunch", "L", "Deconstructed Burrito Bowl (Day 3 Chicken)", 5, ["chickenThighs", "rice", "beans", "hardCheese", "greekYogurt"], "soft finger", m(21, 10, 28, 2.3),
     ["Reheat Day 3 shredded chicken, rice, and beans until steaming, then cool to warm.", "Arrange in separate piles; top with shredded cheddar and a Greek yogurt dollop."], True),
    (5, "afternoonSnack", "S", "Crackers with Thin Almond Butter & Raspberries", 3, ["crackers", "nutButter", "berries"], "finger", m(5, 9, 16, 0.9),
     ["Spread a thin smear of almond butter on whole-grain crackers.", "Serve with soft raspberries, torn in half."], False),
    (5, "dinner", "D", "Homemade White Fish Fingers, Potato Wedges & Green Beans", 25, ["whiteFish", "eggs", "panko", "potatoes", "greenBeans"], "crispy finger", m(19, 10, 26, 1.3),
     ["Cut cod or tilapia into strips; dip in beaten egg, then panko.", "Pan-sear in a little oil, 2–3 min per side, until opaque and flaky.", "Roast potato wedges at 425°F / 220°C for 25 min until soft inside.", "Steam green beans until very tender; cut into short pieces."], False),
]

plan = {}
for day, slot, codes, title, mins, keys, tex, macros, steps, plan_only in SEED:
    rid = f"plan-day{day}-{slot}"
    batch = "Cook once, serve twice" in " ".join(steps)
    r(codes, title, mins, keys, tex, steps, macros=macros, plan_only=plan_only, rid=rid, batch=batch)
    plan.setdefault(day, []).append({"slot": slot, "recipeID": rid})

PREP = {
    1: [("Hard-boil 4 eggs", "12 min. Peel and refrigerate for the Day 2 snack and extra protein."),
        ("Cook a base grain", "Make 2 cups rice. Cool within 1 hour and refrigerate for Day 3 and Day 5."),
        ("Wash & quarter produce", "Quarter grapes and cherry tomatoes lengthwise; hull and quarter strawberries."),
        ("Steam & portion edamame", "Steam the whole bag, lightly smash, and portion for Day 1 and Day 4."),
        ("Roast sweet potatoes", "Roast 2 whole sweet potatoes for tonight's mash.")],
    2: [("Make a double batch of Bolognese", "Refrigerate half for Day 3 lunch (use within 3–4 days).")],
    3: [("Shred extra chicken thighs", "Store 1 cup chicken with rice and beans for the Day 5 burrito bowl.")],
    4: [("Rinse red lentils", "No soaking needed. Rinse until the water runs clear."),
        ("Thaw white fish", "Move cod or tilapia from freezer to fridge for tomorrow's fish fingers.")],
}

library = {
    "version": 1,
    "ingredients": list(CATALOG.values()),
    "recipes": RECIPES,
    "defaultPlan": [
        {"dayIndex": d, "meals": plan[d], "prepTasks": [{"title": t, "detail": x} for t, x in PREP.get(d, [])]}
        for d in sorted(plan)
    ],
    "leftoverLinks": [
        {"fromDay": 2, "fromSlot": "dinner", "toDay": 3, "toSlot": "lunch"},
        {"fromDay": 3, "fromSlot": "dinner", "toDay": 5, "toSlot": "lunch"},
    ],
    "defaultSafeFoods": ["banana", "bread", "hardCheese", "greekYogurt"],
}

# --- Validation (mirrors the Swift Codable types) --------------------------------------------
SLOTS = {"breakfast", "morningSnack", "lunch", "afternoonSnack", "dinner"}
TEXTURES = {"softScoopable", "fingerFood", "dippers", "smoothies", "crispy"}
CATEGORIES = {"poultryAndMeat", "seafood", "eggsAndDairy", "plantBasedPantry", "snacksAndBoosters", "produce"}
HAZARDS = {None, "roundFood", "wholeNuts", "nutButter", "toughMeat", "hardRawProduce", "firmCubes", "fishBones",
           "honey", "sausage", "driedFruit"}
ALLERGENS = {"dairy", "egg", "peanut", "treeNut", "soy", "wheat", "fish", "shellfish", "sesame"}
MACRO_KEYS = {"proteinGrams", "healthyFatGrams", "complexCarbGrams", "ironMilligrams"}

errors = []
for i in library["ingredients"]:
    if i["category"] not in CATEGORIES: errors.append(f"{i['key']}: bad category")
    if i["hazard"] not in HAZARDS: errors.append(f"{i['key']}: bad hazard {i['hazard']}")
    if not set(i["allergens"]) <= ALLERGENS: errors.append(f"{i['key']}: bad allergen")
    if set(i["nutrition"]) != MACRO_KEYS: errors.append(f"{i['key']}: bad nutrition keys")

ids = Counter(x["id"] for x in RECIPES)
titles = Counter(x["title"].lower() for x in RECIPES)
errors += [f"duplicate id {k}" for k, v in ids.items() if v > 1]
errors += [f"duplicate title {k}" for k, v in titles.items() if v > 1]
for x in RECIPES:
    if not x["slots"] or not set(x["slots"]) <= SLOTS: errors.append(f"{x['id']}: bad slots")
    if not x["textures"] or not set(x["textures"]) <= TEXTURES: errors.append(f"{x['id']}: bad textures")
    if set(x["macros"]) != MACRO_KEYS: errors.append(f"{x['id']}: bad macros")
    if len(x["steps"]) < 1 or any(not s.strip() for s in x["steps"]): errors.append(f"{x['id']}: bad steps")
    if x["prepTimeMinutes"] <= 0: errors.append(f"{x['id']}: bad prep time")
    if any(k not in CATALOG for k in x["ingredientKeys"]): errors.append(f"{x['id']}: unknown ingredient")
recipe_ids = set(ids)
for d in library["defaultPlan"]:
    for meal in d["meals"]:
        if meal["recipeID"] not in recipe_ids: errors.append(f"plan references missing {meal['recipeID']}")
for k in library["defaultSafeFoods"]:
    if k not in CATALOG: errors.append(f"unknown safe food {k}")

browsable = [x for x in RECIPES if not x["planOnly"]]
if len(browsable) < 400:
    errors.append(f"only {len(browsable)} browsable recipes (need 400+)")

if errors:
    print("\n".join(errors))
    sys.exit(1)

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "LittleBitesMacros", "RecipeLibrary.json")
with open(out, "w", encoding="utf-8") as fh:
    json.dump(library, fh, ensure_ascii=False, indent=1)

by_slot = Counter()
for x in browsable:
    for s in x["slots"]:
        by_slot[s] += 1
print(f"Wrote {os.path.normpath(out)}")
print(f"  {len(CATALOG)} ingredients, {len(browsable)} browsable recipes ({len(RECIPES)} total)")
print("  by slot:", dict(by_slot))
print("  cuisines:", len({x['cuisine'] for x in browsable}))
