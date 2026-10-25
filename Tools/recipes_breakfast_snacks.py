"""Breakfast and snack recipes."""

from recipe_core import r, join

# ============================================================================================
# BREAKFAST
# ============================================================================================

# Soft scrambles
for name, keys, step, cuisine in [
    ("Spinach & Cheddar", ["spinach", "hardCheese"], "Wilt a handful of finely chopped spinach in the pan for 1 minute.", "American"),
    ("Tomato & Basil", ["cherryTomatoes", "herbs"], "Have quartered cherry tomatoes and torn basil ready to stir in at the end.", "Italian-Inspired"),
    ("Mushroom & Parmesan", ["mushrooms", "hardCheese"], "Sauté finely diced mushrooms in butter until very soft.", "French-Inspired"),
    ("Zucchini & Feta", ["zucchini", "feta"], "Grate zucchini, squeeze out the moisture, and soften it in the pan.", "Greek-Inspired"),
    ("Sweet Potato Hash", ["sweetPotato", "bellPepper"], "Warm soft, diced roasted sweet potato and finely chopped pepper in the pan.", "American"),
    ("Flaked Salmon & Dill", ["salmon", "herbs", "creamCheese"], "Warm flaked cooked salmon (bones removed) with a dab of cream cheese and dill.", "Scandinavian-Inspired"),
    ("Black Beans & Avocado", ["beans", "avocado", "salsa"], "Warm mashed black beans in the pan; top the finished eggs with diced avocado and a little salsa.", "Mexican-Inspired"),
    ("Broccoli & Cheddar", ["broccoli", "hardCheese"], "Finely chop steamed broccoli and warm it in the pan.", "American"),
    ("Ham & Peas", ["ham", "peas"], "Warm finely diced ham and smashed peas in the pan.", "British-Inspired"),
]:
    r("B", f"Soft Scrambled Eggs with {name}", 10, ["eggs", "milk", "butter", "bread"] + keys, "soft finger", [
        "Whisk 2 eggs with a splash of milk.",
        step,
        "Pour in the eggs and stir gently over low heat until soft, moist curds form.",
        "Serve with whole-wheat toast strips.",
    ], cuisine)

# Creamy oatmeal
for name, keys, step, cuisine in [
    ("Apple Cinnamon", ["applesPears", "cinnamon"], "Grate a peeled apple into the pot with a pinch of cinnamon.", "American"),
    ("Banana Peanut Butter", ["banana", "nutButter"], "Mash half a banana into the oats, then stir in 1 tsp peanut butter until fully melted in.", "American"),
    ("Pumpkin Pie", ["pumpkinPuree", "cinnamon", "mapleSyrup"], "Stir in 2 tbsp pumpkin purée, cinnamon and a drop of maple syrup.", "American"),
    ("Blueberry Lemon", ["blueberries", "lemon"], "Simmer smashed blueberries with the oats and add a little lemon zest.", "American"),
    ("Peaches & Cream", ["mangoPeach", "vanilla"], "Fold in soft diced peaches and a drop of vanilla.", "American"),
    ("Mango Coconut", ["mangoPeach", "coconutMilk", "shreddedCoconut"], "Cook the oats in half coconut milk; top with diced mango and finely shredded coconut.", "Caribbean-Inspired"),
    ("Chocolate Banana", ["cocoa", "banana"], "Whisk in 1 tsp cocoa powder and mash in half a ripe banana.", "American"),
    ("Carrot Cake", ["carrots", "raisins", "cinnamon"], "Stir in finely grated carrot, cinnamon and finely chopped raisins; simmer until the carrot is soft.", "American"),
    ("Pear & Ginger", ["applesPears", "ginger"], "Add grated peeled pear and a tiny pinch of grated ginger.", "American"),
    ("Strawberry Chia", ["strawberries", "chiaSeeds"], "Stir in 1 tsp chia seeds and mashed strawberries; let stand 2 minutes so the chia softens.", "American"),
    ("PB & J", ["nutButter", "berries"], "Swirl in a thin ribbon of peanut butter and mashed berries.", "American"),
    ("Sweet Potato Pie", ["sweetPotato", "cinnamon"], "Stir in 2 tbsp mashed cooked sweet potato and cinnamon.", "American"),
    ("Raspberry Ricotta", ["berries", "ricotta"], "Top with a spoon of ricotta and mashed raspberries.", "Italian-Inspired"),
]:
    r("B", f"{name} Oatmeal", 8, ["oats", "milk", "greekYogurt"] + keys, "soft", [
        "Simmer ⅓ cup rolled oats in ⅔ cup milk for 5 minutes, stirring, until creamy.",
        step,
        "Off the heat, stir in 2 tbsp Greek yogurt for extra protein.",
        "Cool to warm before serving.",
    ], cuisine)

# Overnight oats
for name, keys, step, cuisine in [
    ("Berry Vanilla", ["berries", "vanilla"], "Fold in mashed berries and a drop of vanilla.", "American"),
    ("Peanut Butter Banana", ["nutButter", "banana"], "Stir in 1 tsp peanut butter (fully mixed in) and mashed banana.", "American"),
    ("Apple Pie", ["appleSauce", "cinnamon"], "Swirl in 2 tbsp applesauce and a pinch of cinnamon.", "American"),
    ("Mango Lassi", ["mangoPeach", "spices"], "Fold in puréed mango and a tiny pinch of cardamom.", "Indian-Inspired"),
    ("Tropical", ["pineappleMelon", "coconutMilk"], "Use coconut milk for half the milk and fold in finely diced pineapple.", "Caribbean-Inspired"),
    ("Carrot Cake", ["carrots", "cinnamon", "raisins"], "Stir in finely grated carrot, cinnamon and finely chopped raisins.", "American"),
    ("Pumpkin Spice", ["pumpkinPuree", "cinnamon"], "Stir in 2 tbsp pumpkin purée and cinnamon.", "American"),
    ("Chocolate Raspberry", ["cocoa", "berries"], "Whisk in 1 tsp cocoa and fold in mashed raspberries.", "American"),
    ("Kiwi Coconut", ["kiwi", "shreddedCoconut"], "Top with finely diced kiwi and a sprinkle of shredded coconut.", "American"),
]:
    r("B", f"{name} Overnight Oats", 5, ["oats", "milk", "greekYogurt", "chiaSeeds"] + keys, "soft", [
        "Stir ¼ cup rolled oats, ¼ cup milk, ¼ cup Greek yogurt and 1 tsp chia seeds together in a jar.",
        step,
        "Cover and refrigerate overnight until soft and spoonable.",
        "Stir well and serve cold or gently warmed.",
    ], cuisine)

# Pancakes
for title, keys, mix, cuisine in [
    ("Banana Oat Blender Pancakes", ["banana", "eggs", "oats"], "Blend 1 ripe banana, 2 eggs and ¼ cup oats until smooth.", "American"),
    ("Pumpkin Spice Pancakes", ["pumpkinPuree", "eggs", "flour", "milk", "cinnamon", "bakingPowder"], "Whisk ¼ cup pumpkin purée, 1 egg, ½ cup flour, ⅓ cup milk, cinnamon and 1 tsp baking powder.", "American"),
    ("Sweet Potato Pancakes", ["sweetPotato", "eggs", "oats", "cinnamon"], "Blend ½ cup mashed sweet potato, 2 eggs, ¼ cup oats and cinnamon.", "American"),
    ("Cottage Cheese Protein Pancakes", ["cottageCheese", "eggs", "oats"], "Blend ½ cup cottage cheese, 2 eggs and ⅓ cup oats until smooth.", "American"),
    ("Green Monster Spinach Pancakes", ["spinach", "banana", "eggs", "oats", "milk"], "Blend a handful of spinach, 1 banana, 1 egg, ½ cup oats and a splash of milk until bright green.", "American"),
    ("Blueberry Yogurt Pancakes", ["blueberries", "flour", "eggs", "milk", "bakingPowder"], "Whisk ½ cup flour, 1 tsp baking powder, ¼ cup Greek yogurt, 1 egg and a splash of milk; fold in halved blueberries.", "American"),
    ("Apple Cinnamon Pancakes", ["applesPears", "flour", "eggs", "milk", "cinnamon", "bakingPowder"], "Whisk ½ cup flour, 1 tsp baking powder, 1 egg and ⅓ cup milk; fold in finely grated peeled apple and cinnamon.", "American"),
    ("Carrot Cake Pancakes", ["carrots", "flour", "eggs", "milk", "cinnamon", "bakingPowder"], "Whisk ½ cup flour, 1 tsp baking powder, 1 egg and ⅓ cup milk; fold in finely grated carrot and cinnamon.", "American"),
    ("Lemon Ricotta Pancakes", ["ricotta", "lemon", "flour", "eggs", "bakingPowder"], "Whisk ⅓ cup ricotta, 1 egg, lemon zest, ⅓ cup flour and 1 tsp baking powder.", "Italian-Inspired"),
    ("Chocolate Banana Pancakes", ["cocoa", "banana", "eggs", "oats"], "Blend 1 banana, 2 eggs, ¼ cup oats and 1 tsp cocoa.", "American"),
    ("Savory Zucchini Cheddar Pancakes", ["zucchini", "hardCheese", "eggs", "flour"], "Mix grated, squeezed zucchini with 1 egg, 3 tbsp flour and shredded cheddar.", "American"),
    ("Peanut Butter Banana Pancakes", ["nutButter", "banana", "flour", "eggs", "milk", "bakingPowder"], "Whisk 1 tbsp peanut butter (fully blended in) with mashed banana, 1 egg, ⅓ cup milk, ½ cup flour and 1 tsp baking powder.", "American"),
    ("Kefir Berry Pancakes", ["kefir", "flour", "eggs", "bakingPowder", "berries"], "Whisk ½ cup kefir, 1 egg, ½ cup flour and 1 tsp baking powder; fold in mashed berries.", "American"),
    ("Pear Ginger Oat Pancakes", ["applesPears", "ginger", "oats", "eggs"], "Blend a peeled ripe pear, a pinch of ginger, 2 eggs and ¼ cup oats.", "American"),
]:
    r("B", title, 15, keys + ["greekYogurt"], "finger dip", [
        mix,
        "Cook small silver-dollar pancakes over medium-low heat, 1–2 minutes per side.",
        "Cut into strips and serve with a Greek yogurt dip.",
        "Freeze extras between sheets of parchment for busy mornings.",
    ], cuisine, batch=True)

# Mini egg muffins
for name, keys in [
    ("Spinach & Feta", ["spinach", "feta"]),
    ("Broccoli & Cheddar", ["broccoli", "hardCheese"]),
    ("Ham & Cheese", ["ham", "hardCheese"]),
    ("Turkey & Pepper", ["groundTurkey", "bellPepper"]),
    ("Sweet Potato & Black Bean", ["sweetPotato", "beans"]),
    ("Mushroom & Cheese", ["mushrooms", "hardCheese"]),
    ("Salmon & Dill", ["salmon", "herbs"]),
    ("Tomato & Mozzarella", ["cherryTomatoes", "mozzarella"]),
    ("Zucchini & Parmesan", ["zucchini", "hardCheese"]),
    ("Kale & Potato", ["kale", "potatoes"]),
]:
    r("BS", f"Mini {name} Egg Muffins", 25, ["eggs", "milk"] + keys, "finger", [
        "Heat the oven to 350°F / 175°C and grease a mini-muffin tin.",
        "Whisk 6 eggs with ¼ cup milk.",
        f"Divide finely chopped {join(keys)} among the cups, then pour in the egg mixture.",
        "Bake 12–15 minutes until set; cool and halve for small hands.",
        "Refrigerate up to 4 days or freeze for quick breakfasts.",
    ], batch=True)

# French toast fingers
for name, keys, step in [
    ("Classic Cinnamon", ["cinnamon", "vanilla"], "Whisk cinnamon and a drop of vanilla into the custard."),
    ("Pumpkin", ["pumpkinPuree", "cinnamon"], "Whisk 2 tbsp pumpkin purée and cinnamon into the custard."),
    ("Banana Vanilla", ["banana", "vanilla"], "Mash half a banana and a drop of vanilla into the custard."),
    ("Berry-Stuffed", ["creamCheese", "berries"], "Sandwich a thin layer of cream cheese and mashed berries between two slices before dipping."),
    ("Apple Pie", ["appleSauce", "cinnamon"], "Add cinnamon to the custard and warm some applesauce for dipping."),
    ("Coconut Mango", ["coconutMilk", "mangoPeach"], "Use coconut milk in the custard and purée mango for dipping."),
]:
    r("B", f"{name} French Toast Fingers", 12, ["bread", "eggs", "milk", "butter"] + keys, "finger dip", [
        "Whisk 1 egg with 3 tbsp milk.",
        step,
        "Soak bread strips 10 seconds per side, then cook in a little butter over medium-low until golden and set.",
        "Cool slightly and serve as fingers.",
    ])

# Yogurt bowls
for title, keys, step in [
    ("Berry Crunch Yogurt Bowl", ["berries", "oats", "hempSeeds"], "Top with mashed berries, soft-soaked oats and a sprinkle of hemp seeds."),
    ("Mango Coconut Yogurt Bowl", ["mangoPeach", "shreddedCoconut"], "Top with finely diced ripe mango and shredded coconut."),
    ("Peach Melba Yogurt Bowl", ["mangoPeach", "berries"], "Top with soft diced peaches and mashed raspberries."),
    ("Peanut Butter Banana Yogurt Bowl", ["nutButter", "banana"], "Swirl in 1 tsp peanut butter thinned with warm water; top with thin banana slices."),
    ("Kiwi & Chia Yogurt Bowl", ["kiwi", "chiaSeeds"], "Stir in 1 tsp chia seeds, wait 5 minutes for them to soften, and top with finely diced kiwi."),
    ("Apple Pie Yogurt Bowl", ["appleSauce", "cinnamon", "oats"], "Swirl in applesauce and cinnamon; top with soft-soaked oats."),
    ("Pumpkin Pie Yogurt Bowl", ["pumpkinPuree", "cinnamon", "mapleSyrup"], "Stir in pumpkin purée, cinnamon and a drop of maple syrup."),
    ("Tropical Yogurt Bowl", ["pineappleMelon", "mangoPeach", "shreddedCoconut"], "Top with finely diced pineapple and mango and a little coconut."),
    ("Strawberry Flax Yogurt Bowl", ["strawberries", "flaxseed"], "Top with quartered strawberries and a spoon of ground flaxseed."),
]:
    r("BS", title, 4, ["greekYogurt"] + keys, "soft", [
        "Spoon ½ cup plain Greek yogurt into a bowl.",
        step,
        "Serve with a pre-loaded spoon so your toddler can practice self-feeding.",
    ])

# Toast fingers
for title, keys, steps, cuisine in [
    ("Avocado & Egg Toast Fingers", ["avocado", "eggs"], ["Toast the bread and mash ripe avocado on top.", "Top with a finely chopped hard-boiled egg.", "Cut into fingers."], "American"),
    ("Peanut Butter & Banana Toast Fingers", ["nutButter", "banana"], ["Toast the bread and spread a thin smear of peanut butter.", "Top with thin banana slices and press down lightly.", "Cut into fingers."], "American"),
    ("Ricotta, Berry & Honey Toast", ["ricotta", "berries", "honey"], ["Toast the bread and spread with ricotta.", "Top with mashed berries and a tiny drizzle of honey (12 months+ only).", "Cut into fingers."], "Italian-Inspired"),
    ("Hummus & Cucumber Toast", ["hummus", "cucumber"], ["Toast the bread and spread with hummus.", "Top with paper-thin peeled cucumber slices.", "Cut into fingers."], "Middle Eastern-Inspired"),
    ("Cottage Cheese & Tomato Toast", ["cottageCheese", "cherryTomatoes", "oliveOil"], ["Toast the bread and spread with cottage cheese.", "Top with quartered cherry tomatoes and a drop of olive oil.", "Cut into fingers."], "Mediterranean"),
    ("Sardine & Avocado Toast", ["sardines", "avocado", "lemon"], ["Mash sardines with avocado and a squeeze of lemon, checking for any bones.", "Spread on toast.", "Cut into fingers."], "Mediterranean"),
    ("Strawberry Cream Cheese Toast", ["creamCheese", "strawberries"], ["Toast the bread and spread a thin layer of cream cheese.", "Top with thinly sliced strawberries.", "Cut into fingers."], "American"),
    ("Sunflower Butter & Apple Toast", ["seedButter", "applesPears"], ["Toast the bread and spread a thin smear of sunflower seed butter.", "Top with grated or paper-thin peeled apple.", "Cut into fingers."], "American"),
    ("Cheesy Bean Toast", ["beans", "hardCheese"], ["Mash warm beans onto toast.", "Sprinkle with cheddar and broil 1 minute until melted.", "Cool and cut into fingers."], "British-Inspired"),
    ("Tahini Banana Toast", ["tahini", "banana", "cinnamon"], ["Toast the bread and spread a thin layer of tahini.", "Top with mashed banana and a pinch of cinnamon.", "Cut into fingers."], "Middle Eastern-Inspired"),
]:
    r("BS", title, 6, ["bread"] + keys, "finger", steps, cuisine)

# Breakfast quesadillas
for title, keys, step in [
    ("Egg & Cheese Breakfast Quesadilla", ["eggs", "hardCheese"], "Soft-scramble 1 egg and spread over half a tortilla with shredded cheddar."),
    ("Bean & Egg Breakfast Quesadilla", ["beans", "eggs", "hardCheese"], "Spread mashed beans and soft-scrambled egg over half a tortilla with a little cheese."),
    ("Sweet Potato & Black Bean Breakfast Quesadilla", ["sweetPotato", "beans", "hardCheese"], "Spread mashed sweet potato and black beans over half a tortilla; sprinkle with cheese."),
    ("Spinach, Egg & Feta Breakfast Quesadilla", ["spinach", "eggs", "feta"], "Scramble an egg with chopped spinach and feta and spread over half a tortilla."),
]:
    r("B", title, 12, ["tortillas"] + keys, "finger crispy", [
        step,
        "Fold and toast in a dry pan 2–3 minutes per side until golden.",
        "Cool slightly and cut into small triangles.",
    ], "Mexican-Inspired")

# Waffles
for title, keys in [
    ("Spinach Banana Waffles", ["spinach", "banana", "flour", "eggs", "milk", "bakingPowder"]),
    ("Sweet Potato Waffles", ["sweetPotato", "flour", "eggs", "milk", "bakingPowder", "cinnamon"]),
    ("Protein Oat Waffles", ["cottageCheese", "oats", "eggs", "bakingPowder"]),
    ("Carrot Cake Waffles", ["carrots", "flour", "eggs", "milk", "cinnamon", "bakingPowder"]),
    ("Pumpkin Waffles", ["pumpkinPuree", "flour", "eggs", "milk", "cinnamon", "bakingPowder"]),
    ("Blueberry Kefir Waffles", ["blueberries", "kefir", "flour", "eggs", "bakingPowder"]),
]:
    r("B", title, 20, keys + ["greekYogurt"], "finger dip crispy", [
        f"Blend or whisk {join(keys, skip_seasonings=True)} with the leavening and spices into a thick batter.",
        "Cook in a lightly greased waffle iron until golden.",
        "Cut into strips for dipping in Greek yogurt.",
        "Freeze extras and re-crisp them in the toaster.",
    ], batch=True)

# Chia puddings
for title, keys, step in [
    ("Vanilla Berry Chia Pudding", ["vanilla", "berries"], "Stir in vanilla and top with mashed berries."),
    ("Chocolate Banana Chia Pudding", ["cocoa", "banana"], "Whisk in 1 tsp cocoa and top with mashed banana."),
    ("Mango Coconut Chia Pudding", ["mangoPeach", "coconutMilk"], "Make it with half coconut milk and top with mango purée."),
    ("PB & J Chia Pudding", ["nutButter", "berries"], "Swirl in 1 tsp peanut butter (fully mixed) and mashed berries."),
    ("Kefir Strawberry Chia Pudding", ["kefir", "strawberries"], "Use kefir for half the milk and top with mashed strawberries."),
]:
    r("BS", title, 5, ["chiaSeeds", "milk"] + keys, "soft", [
        "Stir 2 tbsp chia seeds into ½ cup milk, wait 5 minutes, then stir again to break up clumps.",
        "Refrigerate at least 2 hours (or overnight) until fully gelled. Chia must always be soaked.",
        step,
        "Serve chilled.",
    ])

# Porridges
r("B", "Apple Cinnamon Quinoa Porridge", 20, ["quinoa", "milk", "applesPears", "cinnamon"], "soft", [
    "Simmer ¼ cup rinsed quinoa in ¾ cup milk for 15 minutes until very soft.",
    "Stir in grated peeled apple and cinnamon for the last 5 minutes.",
    "Cool to warm and serve."])
r("B", "Berry Quinoa Breakfast Bowl", 20, ["quinoa", "milk", "berries", "greekYogurt"], "soft", [
    "Simmer ¼ cup rinsed quinoa in ¾ cup milk until soft and creamy.",
    "Fold in mashed berries.",
    "Top with a spoon of Greek yogurt."])
r("B", "Creamy Rice Pudding Porridge", 15, ["rice", "milk", "cinnamon", "raisins"], "soft", [
    "Simmer ½ cup cooked rice with ¾ cup milk for 10 minutes until creamy.",
    "Stir in cinnamon and finely chopped raisins.",
    "Cool to warm before serving."])
r("B", "Polenta Breakfast Bowl with Berries", 12, ["polenta", "milk", "berries", "mapleSyrup"], "soft", [
    "Whisk 3 tbsp polenta into 1 cup simmering milk and cook 8 minutes, stirring, until thick.",
    "Top with mashed berries and a drop of maple syrup.",
    "Cool to warm."], "Italian-Inspired")
r("B", "Cheesy Polenta with Soft Egg", 15, ["polenta", "milk", "hardCheese", "eggs"], "soft", [
    "Cook polenta in milk until thick and creamy.",
    "Stir in grated cheddar or parmesan.",
    "Top with a finely chopped soft-scrambled egg."], "Italian-Inspired")

# Frittata fingers
for name, keys in [
    ("Potato & Pea", ["potatoes", "peas"]),
    ("Spinach & Ricotta", ["spinach", "ricotta"]),
    ("Broccoli & Cheddar", ["broccoli", "hardCheese"]),
    ("Zucchini & Tomato", ["zucchini", "cherryTomatoes"]),
    ("Kale & Feta", ["kale", "feta"]),
    ("Sweet Potato & Chicken Sausage", ["sweetPotato", "chickenSausage"]),
]:
    r("BL", f"{name} Frittata Fingers", 25, ["eggs", "milk", "oliveOil"] + keys, "finger", [
        "Heat the oven to 375°F / 190°C.",
        f"Soften finely chopped {join(keys)} in an oven-safe pan with a little oil.",
        "Pour over 6 eggs whisked with ¼ cup milk and cook 2 minutes on the stove.",
        "Bake 12–15 minutes until set; cool and cut into fingers.",
    ], "Italian-Inspired", batch=True)

# Savory & global breakfasts
r("BL", "Mild Chicken & Ginger Congee", 70, ["rice", "chickenThighs", "broth", "ginger", "spinach"], "soft", [
    "Simmer ½ cup rice in 4 cups low-sodium broth with a slice of ginger for 60 minutes, stirring often, until porridge-like.",
    "Stir in finely shredded cooked chicken and chopped spinach.",
    "Remove the ginger and cool to warm."], "Asian-Inspired", batch=True)
r("B", "Egg Drop Congee with Peas", 45, ["rice", "broth", "eggs", "peas"], "soft", [
    "Simmer ⅓ cup rice in 3 cups low-sodium broth for 40 minutes until very soft.",
    "Drizzle in a beaten egg while stirring to make silky ribbons.",
    "Stir in smashed peas and cool to warm."], "Asian-Inspired")
r("B", "Savory Oatmeal with Egg & Cheese", 10, ["oats", "broth", "eggs", "hardCheese"], "soft", [
    "Cook ⅓ cup oats in low-sodium broth until creamy.",
    "Stir in shredded cheese.",
    "Top with a finely chopped soft-cooked egg."])
r("BS", "Breakfast Sweet Potato Boats", 10, ["sweetPotato", "greekYogurt", "nutButter", "cinnamon"], "soft", [
    "Microwave or roast a sweet potato until very soft; halve it.",
    "Mash the flesh in the skin with cinnamon.",
    "Top with Greek yogurt and a thin drizzle of peanut butter thinned with warm water."])
r("BL", "Mild Shakshuka with Toast Soldiers", 20, ["eggs", "tomatoes", "bellPepper", "onion", "spices", "bread"], "soft dip", [
    "Soften finely diced onion and pepper in a pan, then add crushed tomatoes and a pinch of cumin; simmer 8 minutes.",
    "Make wells and crack in 2 eggs; cover and cook until the whites and yolks are fully set.",
    "Serve with toast fingers for dipping."], "Middle Eastern-Inspired")
r("B", "Tofu Scramble with Spinach", 10, ["tofu", "spinach", "spices", "bread"], "soft finger", [
    "Crumble firm tofu into a pan with a pinch of turmeric and cumin.",
    "Stir in finely chopped spinach and cook until wilted.",
    "Serve with toast strips."])
r("B", "Southwest Tofu Scramble", 12, ["tofu", "beans", "bellPepper", "salsa", "tortillas"], "soft finger", [
    "Crumble tofu into a pan with finely diced pepper.",
    "Add mashed black beans and a spoon of mild salsa; heat through.",
    "Serve with warm tortilla strips."], "Mexican-Inspired")
r("BS", "Peaches & Cottage Cheese Bowl", 3, ["cottageCheese", "mangoPeach", "cinnamon"], "soft", [
    "Spoon ⅓ cup cottage cheese into a bowl.",
    "Top with soft diced peaches and a pinch of cinnamon."])
r("BS", "Savory Cottage Cheese & Cucumber Bowl", 4, ["cottageCheese", "cucumber", "cherryTomatoes", "oliveOil"], "soft", [
    "Spoon ⅓ cup cottage cheese into a bowl.",
    "Top with finely diced peeled cucumber, quartered cherry tomatoes and a drop of olive oil."], "Mediterranean")
r("B", "Breakfast Burrito Bites", 15, ["eggs", "beans", "hardCheese", "tortillas", "salsa"], "finger", [
    "Soft-scramble 2 eggs with mashed beans and cheese.",
    "Roll tightly in a tortilla and toast seam-side down until golden.",
    "Slice into 1-inch bites; serve with mild salsa."], "Mexican-Inspired", batch=True)
r("B", "Japanese-Style Breakfast Plate", 15, ["rice", "eggs", "salmon", "edamame"], "finger soft", [
    "Make a thin rolled omelet (tamago) and slice it into strips.",
    "Flake cooked salmon, checking for bones.",
    "Serve with soft rice and smashed edamame."], "Japanese-Inspired")
r("B", "Egg-in-a-Hole Toast", 8, ["bread", "eggs", "butter"], "finger", [
    "Cut a hole in a slice of bread and toast it in butter.",
    "Crack an egg into the hole and cook until fully set on both sides.",
    "Cut into fingers."])
r("BS", "Banana Bread Baked Oatmeal", 35, ["oats", "banana", "eggs", "milk", "cinnamon", "bakingPowder"], "soft finger", [
    "Heat the oven to 350°F / 175°C.",
    "Mix 2 cups oats, 2 mashed bananas, 2 eggs, 1½ cups milk, cinnamon and 1 tsp baking powder.",
    "Bake in a greased dish for 30 minutes until set; cut into squares."], batch=True)
r("B", "Huevos Rancheros Bites", 15, ["eggs", "refriedBeans", "tortillas", "salsa", "avocado"], "finger", [
    "Toast small tortilla rounds until just crisp.",
    "Spread with warm refried beans and top with a fully cooked scrambled egg.",
    "Add a little mild salsa and mashed avocado."], "Mexican-Inspired")
r("B", "Salmon & Cream Cheese English Muffin", 8, ["englishMuffins", "creamCheese", "salmon", "cucumber"], "finger", [
    "Toast an English muffin and spread with cream cheese.",
    "Top with flaked cooked salmon and paper-thin cucumber.",
    "Cut into small wedges."], "Scandinavian-Inspired")
r("B", "Cheesy Egg English Muffin Sandwich", 10, ["englishMuffins", "eggs", "hardCheese"], "finger", [
    "Cook an egg flat in a small pan until fully set.",
    "Sandwich in a toasted English muffin with a thin slice of cheese.",
    "Cut into quarters."])

# ============================================================================================
# SNACKS
# ============================================================================================

for title, keys, steps in [
    ("Apple Slices with Cinnamon Yogurt Dip", ["applesPears", "greekYogurt", "cinnamon"], ["Peel and slice an apple paper-thin (or steam slices 2 minutes to soften).", "Stir cinnamon into ¼ cup Greek yogurt for dipping."]),
    ("Pear Fingers with Vanilla Ricotta Dip", ["applesPears", "ricotta", "vanilla"], ["Peel a very ripe pear and cut into soft fingers.", "Whip ricotta with a drop of vanilla for dipping."]),
    ("Banana Spears with Sunflower Butter Drizzle", ["banana", "seedButter"], ["Cut a banana lengthwise into spears.", "Thin 1 tsp sunflower seed butter with warm water and drizzle it thinly over the top."]),
    ("Melon Sticks with Mint Yogurt", ["pineappleMelon", "greekYogurt", "herbs"], ["Cut ripe melon into finger-size sticks.", "Stir finely chopped mint into Greek yogurt for dipping."]),
    ("Strawberries with Chocolate Yogurt Dip", ["strawberries", "greekYogurt", "cocoa", "mapleSyrup"], ["Hull and quarter strawberries.", "Whisk cocoa and a drop of maple syrup into Greek yogurt."]),
    ("Mango Spears with Coconut Yogurt", ["mangoPeach", "greekYogurt", "shreddedCoconut"], ["Cut ripe mango into spears.", "Stir finely shredded coconut into Greek yogurt for dipping."]),
    ("Peach Slices with Cottage Cheese", ["mangoPeach", "cottageCheese"], ["Peel and slice a ripe peach into thin wedges.", "Serve with a scoop of cottage cheese."]),
    ("Kiwi Moons with Vanilla Yogurt", ["kiwi", "greekYogurt", "vanilla"], ["Peel kiwi and cut into thin half-moons.", "Serve with vanilla-flavored Greek yogurt."]),
    ("Steamed Apple Fingers with Peanut Butter Dip", ["applesPears", "nutButter", "greekYogurt"], ["Steam peeled apple fingers 3 minutes until just soft.", "Whisk 1 tsp peanut butter into 3 tbsp Greek yogurt for a thin, toddler-safe dip."]),
    ("Pineapple with Lime Yogurt", ["pineappleMelon", "greekYogurt", "lemon"], ["Cut ripe pineapple into thin sticks, removing the core.", "Stir a little lime or lemon zest into Greek yogurt."]),
    ("Mandarin Segments with Cream Cheese Dip", ["mandarin", "creamCheese", "milk"], ["Peel mandarin segments and cut each in half.", "Whip cream cheese with a splash of milk until dippable."]),
    ("Blueberry Ricotta Rice Cakes", ["blueberries", "riceCakes", "ricotta"], ["Spread ricotta on a rice cake.", "Top with smashed blueberries and break into pieces."]),
]:
    r("S", title, 5, keys, "finger dip", steps)

for title, keys in [
    ("Oat & Sunflower Butter Bites", ["oats", "seedButter", "honey", "chiaSeeds"]),
    ("Chocolate Date Bites", ["dates", "cocoa", "oats", "hempSeeds"]),
    ("Carrot Cake Bites", ["oats", "carrots", "dates", "cinnamon", "shreddedCoconut"]),
    ("Pumpkin Pie Bites", ["oats", "pumpkinPuree", "seedButter", "cinnamon"]),
    ("Lemon Coconut Bites", ["oats", "shreddedCoconut", "lemon", "dates"]),
    ("Peanut Butter Banana Bites", ["oats", "nutButter", "banana", "flaxseed"]),
    ("Apple Cinnamon Bites", ["oats", "appleSauce", "cinnamon", "hempSeeds"]),
    ("Tahini Date Bites", ["oats", "tahini", "dates", "cinnamon"]),
]:
    r("S", title, 15, keys, "finger", [
        f"Pulse {join(keys)} in a food processor until the mixture holds together (any dried fruit must be fully blended).",
        "Press into small, flattened discs. Flat is safer than round balls for little ones.",
        "Chill 30 minutes. Keeps 5 days in the fridge.",
    ], batch=True)

for title, keys in [
    ("Banana Oat Mini Muffins", ["banana", "oats", "eggs", "greekYogurt", "bakingPowder"]),
    ("Zucchini Chocolate Mini Muffins", ["zucchini", "flour", "cocoa", "eggs", "appleSauce", "bakingPowder"]),
    ("Carrot Apple Mini Muffins", ["carrots", "applesPears", "flour", "eggs", "cinnamon", "bakingPowder"]),
    ("Blueberry Yogurt Mini Muffins", ["blueberries", "greekYogurt", "flour", "eggs", "bakingPowder"]),
    ("Pumpkin Spice Mini Muffins", ["pumpkinPuree", "flour", "eggs", "cinnamon", "mapleSyrup", "bakingPowder"]),
    ("Sweet Potato Mini Muffins", ["sweetPotato", "oats", "eggs", "cinnamon", "bakingPowder"]),
    ("Spinach Banana 'Hulk' Mini Muffins", ["spinach", "banana", "oats", "eggs", "bakingPowder"]),
    ("Applesauce Oat Mini Muffins", ["appleSauce", "oats", "eggs", "cinnamon", "bakingPowder"]),
    ("Cheddar Broccoli Mini Muffins", ["broccoli", "hardCheese", "flour", "eggs", "milk", "bakingPowder"]),
    ("Corn & Cheddar Mini Muffins", ["polenta", "corn", "hardCheese", "eggs", "milk", "bakingPowder"]),
]:
    r("SB", title, 25, keys, "finger", [
        "Heat the oven to 350°F / 175°C and line a mini-muffin tin.",
        f"Mix {join(keys, skip_seasonings=True)} (finely grated or mashed) with the spices until just combined.",
        "Fill cups ¾ full and bake 12–14 minutes until a toothpick comes out clean.",
        "Cool completely; freeze extras for up to 3 months.",
    ], batch=True)

for title, keys, steps, cuisine, mins, tex in [
    ("Cucumber Sticks with Tzatziki", ["cucumber", "greekYogurt", "herbs", "lemon"], ["Peel cucumber and cut into thin sticks.", "Stir grated cucumber, dill and a squeeze of lemon into Greek yogurt."], "Greek-Inspired", 6, "finger dip"),
    ("Soft Carrot Sticks with Hummus", ["carrots", "hummus"], ["Steam carrot sticks 6–8 minutes until soft enough to squish.", "Serve with hummus for dipping."], "Middle Eastern-Inspired", 10, "finger dip"),
    ("Steamed Pepper Strips with Guacamole", ["bellPepper", "avocado", "lemon"], ["Steam pepper strips 4 minutes until bendable.", "Mash avocado with a squeeze of lemon."], "Mexican-Inspired", 8, "finger dip"),
    ("Baked Zucchini Fries with Yogurt Ranch", ["zucchini", "panko", "eggs", "hardCheese", "greekYogurt", "herbs"], ["Cut zucchini into sticks, dip in beaten egg, then in a panko and parmesan mix.", "Bake at 425°F / 220°C for 18 minutes until golden.", "Mix Greek yogurt with dill and chives for dipping."], "American", 25, "finger dip crispy"),
    ("Sweet Potato Wedges with Black Bean Dip", ["sweetPotato", "beans", "oliveOil", "spices"], ["Roast sweet potato wedges at 425°F / 220°C for 25 minutes until soft inside.", "Blend black beans with olive oil and a pinch of cumin until smooth."], "Latin American-Inspired", 30, "finger dip"),
    ("Broccoli Trees with Cheese Sauce", ["broccoli", "hardCheese", "milk", "flour", "butter"], ["Steam broccoli florets until very tender.", "Make a quick cheese sauce: melt butter, whisk in flour and milk, then stir in cheddar."], "American", 15, "finger dip"),
    ("Green Beans with White Bean Dip", ["greenBeans", "whiteBeans", "lemon", "oliveOil"], ["Steam green beans until very tender.", "Blend white beans with lemon and olive oil until smooth."], "Mediterranean", 12, "finger dip"),
    ("Edamame Hummus with Pita", ["edamame", "lemon", "oliveOil", "pita"], ["Blend thawed edamame with lemon, olive oil and a splash of water until very smooth.", "Serve with soft pita triangles."], "Asian-Inspired", 8, "dip"),
]:
    r("S", title, mins, keys, tex, steps, cuisine)

for title, keys, steps in [
    ("Hard-Boiled Egg & Avocado Mash on Crackers", ["eggs", "avocado", "crackers"], ["Mash a hard-boiled egg with ripe avocado.", "Spread on crackers."]),
    ("Greek Yogurt 'Deviled' Eggs", ["eggs", "greekYogurt", "spices"], ["Halve hard-boiled eggs and mash the yolks with Greek yogurt and a pinch of paprika.", "Spoon back into the whites; cut each half in two."]),
    ("Mini Cheese Omelet Strips", ["eggs", "hardCheese", "milk"], ["Whisk an egg with milk and cook a thin omelet with cheese until fully set.", "Roll and slice into strips."]),
    ("Egg Salad on Crackers", ["eggs", "greekYogurt", "crackers"], ["Finely chop a hard-boiled egg and mix with Greek yogurt.", "Spread on crackers."]),
    ("Spinach Egg Mug Bites", ["eggs", "spinach", "hardCheese"], ["Whisk an egg with chopped spinach and cheese in a mug.", "Microwave 60–90 seconds until fully set; cool and cut into cubes."]),
]:
    r("S", title, 6, keys, "finger", steps)

for title, keys, cuisine in [
    ("Berry Blast Smoothie", ["berries", "greekYogurt", "milk", "banana"], "American"),
    ("Green Pineapple Kale Smoothie", ["kale", "pineappleMelon", "banana", "kefir"], "American"),
    ("Tropical Sunshine Smoothie", ["mangoPeach", "pineappleMelon", "greekYogurt", "coconutMilk"], "Caribbean-Inspired"),
    ("PB & J Smoothie", ["nutButter", "berries", "milk", "oats"], "American"),
    ("Orange Creamsicle Smoothie", ["mandarin", "greekYogurt", "vanilla", "milk"], "American"),
    ("Chocolate Banana Protein Smoothie", ["cocoa", "banana", "milk", "nutButter", "greekYogurt"], "American"),
    ("Peach Cobbler Smoothie", ["mangoPeach", "oats", "greekYogurt", "cinnamon", "milk"], "American"),
    ("Mango Lassi Smoothie", ["mangoPeach", "greekYogurt", "milk", "spices"], "Indian-Inspired"),
    ("Beet Berry Smoothie", ["beets", "berries", "kefir", "banana"], "American"),
    ("Pumpkin Pie Smoothie", ["pumpkinPuree", "banana", "milk", "cinnamon", "greekYogurt"], "American"),
    ("Avocado Banana Smoothie", ["avocado", "banana", "milk", "hempSeeds"], "American"),
    ("Kiwi Spinach Smoothie", ["kiwi", "spinach", "banana", "kefir"], "American"),
    ("Strawberry Cottage Cheese Smoothie", ["strawberries", "cottageCheese", "milk", "banana"], "American"),
]:
    r("S", title, 5, keys, "smooth", [
        f"Add {join(keys)} to a blender.",
        "Blend until completely smooth with no chunks.",
        "Serve in an open or straw cup; freeze leftovers as pops.",
    ], cuisine)

for title, keys, steps in [
    ("Berry Yogurt Bark", ["greekYogurt", "berries", "honey"], ["Spread 1 cup Greek yogurt on a parchment-lined tray.", "Top with mashed berries and a drizzle of honey (12 months+ only).", "Freeze 2 hours and break into pieces; serve slightly softened."]),
    ("Mango Coconut Yogurt Bark", ["greekYogurt", "mangoPeach", "shreddedCoconut"], ["Spread Greek yogurt on a lined tray and swirl in mango purée.", "Sprinkle with coconut and freeze 2 hours.", "Break into pieces and let soften slightly."]),
    ("Peanut Butter Banana Yogurt Bark", ["greekYogurt", "nutButter", "banana"], ["Spread Greek yogurt on a lined tray.", "Swirl in thinned peanut butter and top with mashed banana.", "Freeze, break into pieces and soften slightly."]),
    ("Frozen Yogurt Melts", ["greekYogurt", "berries"], ["Blend Greek yogurt and berries until smooth.", "Pipe small dots onto a lined tray.", "Freeze until firm; they melt quickly in little mouths."]),
    ("Chocolate Yogurt Frozen Banana Pops", ["banana", "greekYogurt", "cocoa"], ["Halve bananas and insert a wide craft stick.", "Dip in Greek yogurt mixed with cocoa.", "Freeze 2 hours; let soften a few minutes before serving."]),
    ("Strawberry Cottage Cheese 'Ice Cream'", ["cottageCheese", "strawberries", "mapleSyrup"], ["Blend cottage cheese, frozen strawberries and a little maple syrup until smooth.", "Freeze 30 minutes for a soft-serve texture."]),
]:
    r("S", title, 10, keys, "soft finger", steps, batch=True)

for title, keys, steps, tex in [
    ("Cheddar & Apple Cracker Stacks", ["hardCheese", "applesPears", "crackers"], ["Top crackers with thin cheddar slices.", "Add a paper-thin slice of peeled apple."], "finger"),
    ("Cream Cheese & Cucumber Rice Cakes", ["creamCheese", "cucumber", "riceCakes"], ["Spread cream cheese on a rice cake.", "Top with thin peeled cucumber and break into pieces."], "finger"),
    ("Ricotta & Honey Crackers", ["ricotta", "honey", "crackers"], ["Spread ricotta on crackers.", "Drizzle with a little honey (12 months+ only)."], "finger"),
    ("Mini Mozzarella & Tomato Bites", ["mozzarella", "cherryTomatoes", "herbs"], ["Quarter cherry tomatoes lengthwise.", "Toss with small pieces of fresh mozzarella and torn basil."], "finger"),
    ("Parmesan Crisps with Pear", ["hardCheese", "applesPears"], ["Bake small mounds of grated parmesan at 400°F / 200°C for 5 minutes until lacy.", "Serve with very ripe, peeled pear slices."], "finger crispy"),
]:
    r("S", title, 6, keys, tex, steps)

for title, keys, steps in [
    ("Peanut Butter & Banana Rice Cake", ["riceCakes", "nutButter", "banana"], ["Spread a thin smear of peanut butter on a rice cake.", "Top with thin banana slices and break into pieces."]),
    ("Hummus & Cucumber Rice Cake", ["riceCakes", "hummus", "cucumber"], ["Spread hummus on a rice cake.", "Top with paper-thin cucumber and break into pieces."]),
    ("Avocado & Hemp Rice Cake", ["riceCakes", "avocado", "hempSeeds"], ["Mash avocado onto a rice cake.", "Sprinkle with hemp seeds and break into pieces."]),
    ("Sunflower Butter & Strawberry Rice Cake", ["riceCakes", "seedButter", "strawberries"], ["Spread a thin smear of sunflower seed butter on a rice cake.", "Top with thin strawberry slices and break into pieces."]),
]:
    r("S", title, 4, keys, "finger", steps)

for title, keys in [
    ("Turkey & Cream Cheese Pinwheels", ["tortillas", "deliTurkey", "creamCheese"]),
    ("Hummus Veggie Pinwheels", ["tortillas", "hummus", "carrots", "spinach"]),
    ("Sunflower Butter Banana Roll-Ups", ["tortillas", "seedButter", "banana"]),
    ("Spinach & Mozzarella Pinwheels", ["tortillas", "spinach", "mozzarella"]),
    ("Salmon & Cream Cheese Pinwheels", ["tortillas", "salmon", "creamCheese", "herbs"]),
]:
    r("SL", title, 8, keys, "finger", [
        f"Spread a thin, even layer of {join(keys[1:])} over a tortilla (grate any hard veggies finely).",
        "Roll up tightly and chill 10 minutes to firm up.",
        "Slice into ½-inch pinwheels.",
    ])

for title, keys, step in [
    ("Classic Hummus with Soft Pita", ["beans", "tahini", "lemon", "oliveOil", "pita"], "Blend chickpeas with tahini, lemon, olive oil and a splash of water until very smooth."),
    ("Beet Hummus with Pita", ["beans", "beets", "tahini", "lemon", "pita"], "Blend chickpeas with cooked beets, tahini and lemon until bright pink and smooth."),
    ("Sweet Potato Hummus with Crackers", ["beans", "sweetPotato", "tahini", "crackers"], "Blend chickpeas with roasted sweet potato and tahini until smooth."),
    ("White Bean & Herb Dip with Pita", ["whiteBeans", "herbs", "lemon", "oliveOil", "pita"], "Blend white beans with herbs, lemon and olive oil until smooth."),
    ("Avocado Hummus with Crackers", ["beans", "avocado", "lemon", "crackers"], "Blend chickpeas with ripe avocado and lemon until creamy."),
]:
    r("S", title, 8, keys, "dip", [step, "Serve with soft dippers cut into strips or triangles."], "Middle Eastern-Inspired")

for title, keys, steps, cuisine in [
    ("Mini Cheese & Bean Quesadillas", ["tortillas", "beans", "hardCheese"], ["Spread mashed beans and cheese on half a small tortilla and fold.", "Toast in a dry pan until golden; cut into strips."], "Mexican-Inspired"),
    ("Apple Cheddar Quesadilla", ["tortillas", "applesPears", "hardCheese"], ["Layer grated apple and cheddar on half a tortilla and fold.", "Toast until melted; cut into small triangles."], "American"),
    ("Pita Pizza Bites", ["pita", "marinara", "mozzarella"], ["Spread marinara on pita and top with mozzarella.", "Bake at 400°F / 200°C for 8 minutes; cut into small squares."], "Italian-Inspired"),
    ("English Muffin Mini Pizzas", ["englishMuffins", "marinara", "mozzarella", "bellPepper"], ["Top English muffin halves with marinara, mozzarella and finely diced pepper.", "Bake 8–10 minutes until bubbly; cool and cut into wedges."], "Italian-Inspired"),
    ("Spinach Pesto Mozzarella Pita", ["pita", "spinach", "hardCheese", "oliveOil", "mozzarella"], ["Blend spinach, parmesan and olive oil into a nut-free pesto.", "Spread on pita, top with mozzarella and bake 8 minutes; cut into strips."], "Italian-Inspired"),
]:
    r("SL", title, 12, keys, "finger crispy", steps, cuisine)

for title, keys, steps in [
    ("Applesauce Oat Bars", ["oats", "appleSauce", "eggs", "cinnamon"], ["Mix 2 cups oats, 1 cup applesauce, 1 egg and cinnamon.", "Press into a lined pan and bake at 350°F / 175°C for 25 minutes.", "Cool and cut into fingers."]),
    ("Berry Baked Oatmeal Squares", ["oats", "berries", "eggs", "milk", "bakingPowder"], ["Mix oats, mashed berries, eggs, milk and baking powder.", "Bake at 350°F / 175°C for 30 minutes until set.", "Cut into soft squares."]),
    ("Banana Bread Fingers", ["banana", "flour", "eggs", "butter", "bakingPowder"], ["Mix 3 mashed bananas, 2 eggs, melted butter, 1½ cups flour and baking powder.", "Bake in a loaf pan at 350°F / 175°C for 45 minutes.", "Slice and cut into fingers."]),
    ("Pumpkin Oat Bars", ["oats", "pumpkinPuree", "eggs", "mapleSyrup", "cinnamon"], ["Mix oats, pumpkin purée, eggs, a little maple syrup and cinnamon.", "Bake at 350°F / 175°C for 25 minutes.", "Cool and cut into bars."]),
    ("Zucchini Bread Fingers", ["zucchini", "flour", "eggs", "cinnamon", "appleSauce", "bakingPowder"], ["Mix grated zucchini, applesauce, eggs, flour, cinnamon and baking powder.", "Bake in a loaf pan at 350°F / 175°C for 45 minutes.", "Slice into fingers."]),
    ("No-Bake Sunflower Oat Bars", ["oats", "seedButter", "honey", "flaxseed"], ["Warm sunflower seed butter with honey and stir in oats and flaxseed.", "Press firmly into a lined pan and chill 1 hour.", "Cut into thin bars."]),
]:
    r("SB", title, 30, keys, "finger", steps, batch=True)

for title, keys, steps, tex in [
    ("Edamame Smash on Crackers", ["edamame", "crackers", "lemon"], ["Mash thawed, steamed edamame with lemon until smooth.", "Spread on crackers."], "finger"),
    ("Sweet Potato Toast Bites", ["sweetPotato", "nutButter", "banana"], ["Roast thin sweet potato slices until soft.", "Top with a thin smear of peanut butter and mashed banana."], "finger"),
    ("Baked Avocado Fries", ["avocado", "panko", "eggs"], ["Cut firm-ripe avocado into wedges, dip in egg and panko.", "Bake at 425°F / 220°C for 12 minutes until golden."], "finger crispy"),
    ("Soft Fruit & Cheese Stacks", ["pineappleMelon", "hardCheese", "kiwi"], ["Cut melon, kiwi and cheese into thin, flat squares.", "Stack them in mini towers (no skewers)."], "finger"),
    ("Chia Jam Toast Strips", ["bread", "chiaSeeds", "berries"], ["Simmer berries 5 minutes, mash, and stir in chia seeds; let thicken 10 minutes.", "Spread on toast and cut into strips."], "finger"),
    ("Mashed Chickpea Salad Crackers", ["beans", "greekYogurt", "lemon", "crackers"], ["Mash chickpeas with Greek yogurt and lemon.", "Spread on crackers."], "finger"),
    ("Kefir Berry Popsicles", ["kefir", "berries", "honey"], ["Blend kefir, berries and a little honey (12 months+ only).", "Freeze in small pop molds."], "smooth"),
    ("Cinnamon Baked Apple Rings", ["applesPears", "cinnamon", "greekYogurt"], ["Slice peeled, cored apples into thin rings and dust with cinnamon.", "Bake at 375°F / 190°C for 15 minutes until soft; serve with yogurt."], "finger dip"),
    ("Tuna Melt Cracker Bites", ["cannedTuna", "hardCheese", "crackers"], ["Mix drained tuna with a little shredded cheese.", "Spoon onto crackers and broil 1 minute until melted."], "finger"),
]:
    r("S", title, 10, keys, tex, steps)
