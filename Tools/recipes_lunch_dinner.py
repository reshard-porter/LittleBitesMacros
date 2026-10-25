"""Lunch and dinner recipes."""

from recipe_core import r, join

# ============================================================================================
# LUNCH
# ============================================================================================

for title, keys, step in [
    ("Butternut Squash Mac & Cheese", ["butternutSquash"], "Blend 1 cup roasted butternut squash into the sauce."),
    ("Cauliflower Mac & Cheese", ["cauliflower"], "Stir in finely chopped, very soft steamed cauliflower."),
    ("Broccoli Mac & Cheese", ["broccoli"], "Fold in finely chopped steamed broccoli."),
    ("Ham & Pea Mac & Cheese", ["ham", "peas"], "Fold in finely diced ham and smashed peas."),
    ("Tuna Mac & Cheese", ["cannedTuna", "peas"], "Fold in drained, flaked tuna and peas."),
    ("Spinach & White Bean Mac & Cheese", ["spinach", "whiteBeans"], "Blend spinach and white beans into the sauce for hidden protein and iron."),
    ("Sweet Potato Chicken Mac & Cheese", ["sweetPotato", "chickenBreast"], "Blend mashed sweet potato into the sauce and fold in finely shredded cooked chicken."),
]:
    r("LD", title, 20, ["pasta", "milk", "butter", "flour", "hardCheese"] + keys, "soft", [
        "Cook pasta until very soft; drain.",
        "Melt 1 tbsp butter, whisk in 1 tbsp flour, then 1 cup milk; simmer until thickened.",
        step,
        "Stir in shredded cheddar off the heat and toss with the pasta.",
    ], batch=True)

for title, keys, steps, cuisine in [
    ("Chicken Salad Sandwich Fingers", ["chickenBreast", "greekYogurt", "applesPears"], ["Finely shred cooked chicken and mix with Greek yogurt and grated apple.", "Spread on bread and cut into fingers."], "American"),
    ("Egg Salad Sandwich Fingers", ["eggs", "greekYogurt", "herbs"], ["Finely chop hard-boiled eggs and mix with Greek yogurt and a little dill.", "Spread on bread and cut into fingers."], "American"),
    ("Salmon Salad Sandwich Fingers", ["cannedTuna", "greekYogurt", "lemon"], ["Mash canned salmon with Greek yogurt and lemon, checking for bones.", "Spread on bread and cut into fingers."], "American"),
    ("Turkey, Avocado & Cheese Sandwich Fingers", ["deliTurkey", "avocado", "hardCheese"], ["Spread mashed avocado on bread.", "Layer thin turkey strips and a thin slice of cheese; cut into fingers."], "American"),
    ("Hummus & Grated Veggie Sandwich", ["hummus", "carrots", "cucumber"], ["Spread hummus on bread.", "Top with finely grated carrot and cucumber; cut into fingers."], "Middle Eastern-Inspired"),
    ("Grilled Cheese & Apple Fingers", ["hardCheese", "applesPears", "butter"], ["Layer cheddar and paper-thin peeled apple between bread.", "Grill in butter until golden and melted; cut into fingers."], "American"),
    ("Cream Cheese & Cucumber Tea Sandwiches", ["creamCheese", "cucumber", "herbs"], ["Spread cream cheese mixed with dill on bread.", "Add paper-thin peeled cucumber and cut into fingers."], "British-Inspired"),
    ("Smashed Chickpea 'Tuna' Salad Sandwich", ["beans", "greekYogurt", "lemon"], ["Mash chickpeas with Greek yogurt and lemon.", "Spread on bread and cut into fingers."], "American"),
    ("Mozzarella, Tomato & Basil Panini", ["mozzarella", "cherryTomatoes", "herbs", "oliveOil"], ["Fill bread with mozzarella, quartered cherry tomatoes and basil.", "Press in a hot pan with a little oil until melted; cut into fingers."], "Italian-Inspired"),
    ("Sardine Salad Sandwich", ["sardines", "greekYogurt", "lemon"], ["Mash sardines with Greek yogurt and lemon, checking for bones.", "Spread on bread and cut into fingers."], "Mediterranean"),
    ("Ham & Cheese Toastie", ["ham", "hardCheese", "butter"], ["Fill bread with thin ham and cheese.", "Toast in butter until golden and melted; cut into fingers."], "British-Inspired"),
]:
    r("L", title, 8, ["bread"] + keys, "finger", steps, cuisine)

for title, keys in [
    ("Shredded Chicken Quesadilla", ["chickenThighs", "hardCheese"]),
    ("Black Bean & Corn Quesadilla", ["beans", "corn", "hardCheese"]),
    ("Sweet Potato & Mozzarella Quesadilla", ["sweetPotato", "mozzarella"]),
    ("Spinach & Mozzarella Quesadilla", ["spinach", "mozzarella"]),
    ("Refried Bean & Cheese Quesadilla", ["refriedBeans", "hardCheese"]),
    ("Salmon & Avocado Quesadilla", ["salmon", "avocado", "mozzarella"]),
    ("Pulled Pork & Cheese Quesadilla", ["porkShoulder", "hardCheese", "salsa"]),
]:
    r("LD", title, 12, ["tortillas"] + keys + ["greekYogurt"], "finger crispy", [
        f"Spread {join(keys)} (shredded, mashed or finely chopped) over half a tortilla.",
        "Fold and toast in a dry pan 2–3 minutes per side until golden and melted.",
        "Cool slightly and cut into small triangles; serve with Greek yogurt for dipping.",
    ], "Mexican-Inspired")

MEAT_BAKE = "Bake at 400°F / 200°C for 15–18 minutes until cooked through (165°F / 74°C)."
FISH_FRY = "Pan-fry in a little oil, 3 minutes per side, until golden and hot through."
VEG_BAKE = "Bake at 400°F / 200°C for 20 minutes, flipping halfway, until golden."
for title, keys, cook, cuisine, dip in [
    ("Turkey & Spinach Mini Meatballs", ["groundTurkey", "spinach", "panko", "eggs", "hardCheese"], MEAT_BAKE, "Italian-Inspired", "marinara"),
    ("Beef & Veggie Mini Meatballs", ["groundBeef", "carrots", "zucchini", "panko", "eggs"], MEAT_BAKE, "American", "marinara"),
    ("Chicken Zucchini Meatballs", ["groundChicken", "zucchini", "panko", "eggs"], MEAT_BAKE, "American", "greekYogurt"),
    ("Lentil 'Meatballs'", ["lentils", "oats", "eggs", "hardCheese"], VEG_BAKE, "Italian-Inspired", "marinara"),
    ("Baked Salmon Cakes", ["salmon", "potatoes", "eggs", "panko", "herbs"], FISH_FRY, "American", "greekYogurt"),
    ("Tuna Patties", ["cannedTuna", "eggs", "panko", "lemon"], FISH_FRY, "American", "greekYogurt"),
    ("Zucchini Feta Fritters", ["zucchini", "eggs", "flour", "feta"], FISH_FRY, "Greek-Inspired", "greekYogurt"),
    ("Sweet Potato & Black Bean Patties", ["sweetPotato", "beans", "oats", "spices"], VEG_BAKE, "Latin American-Inspired", "greekYogurt"),
    ("Broccoli Cheddar Bites", ["broccoli", "hardCheese", "eggs", "panko"], VEG_BAKE, "American", "greekYogurt"),
    ("Quinoa Veggie Bites", ["quinoa", "carrots", "eggs", "hardCheese"], VEG_BAKE, "American", "greekYogurt"),
    ("Baked Falafel with Yogurt Sauce", ["beans", "herbs", "flour", "spices", "lemon"], VEG_BAKE, "Middle Eastern-Inspired", "greekYogurt"),
]:
    r("LD", title, 25, keys + [dip], "finger dip", [
        f"Combine {join(keys)} (grate or finely chop any veggies) and mix well.",
        "Shape into small, flat patties or slightly flattened balls (flat is safer for toddlers).",
        cook,
        f"Cool, cut in half, and serve with {'marinara' if dip == 'marinara' else 'Greek yogurt'} for dipping.",
    ], cuisine, batch=True)

for title, keys, steps, cuisine, mins in [
    ("Tomato Soup with Grilled Cheese Strips", ["tomatoes", "onion", "broth", "milk", "bread", "hardCheese", "butter"], ["Simmer crushed tomatoes with softened onion and broth for 15 minutes; blend smooth and stir in a splash of milk.", "Make a grilled cheese and cut it into strips for dunking.", "Cool the soup to warm before serving."], "American", 25),
    ("Cozy Chicken Noodle Soup", ["chickenThighs", "eggNoodles", "carrots", "peas", "broth", "onion"], ["Simmer chicken thighs in broth with diced carrot and onion for 25 minutes.", "Shred the chicken finely and return it to the pot with egg noodles and peas; cook until very soft.", "Cool to warm."], "American", 35),
    ("Mild Minestrone", ["whiteBeans", "pasta", "zucchini", "carrots", "tomatoes", "broth"], ["Simmer diced carrot and zucchini in broth and crushed tomatoes for 15 minutes.", "Add small pasta and white beans; cook until the pasta is very soft.", "Mash a few beans to thicken; cool to warm."], "Italian-Inspired", 30),
    ("Butternut Squash Soup", ["butternutSquash", "onion", "broth", "greekYogurt"], ["Simmer cubed squash and onion in broth for 20 minutes until soft.", "Blend until silky.", "Swirl in Greek yogurt and serve warm."], "American", 30),
    ("Red Lentil & Carrot Soup", ["lentils", "carrots", "onion", "broth", "spices"], ["Simmer red lentils, diced carrot and onion in broth with a pinch of cumin for 20 minutes.", "Blend smooth or leave slightly chunky.", "Cool to warm."], "Middle Eastern-Inspired", 25),
    ("Split Pea Soup with Ham", ["splitPeas", "ham", "carrots", "broth"], ["Simmer split peas and diced carrot in broth for 50 minutes until completely soft.", "Stir in finely diced ham.", "Blend partly for a smooth, thick texture."], "American", 60),
    ("White Bean & Kale Soup", ["whiteBeans", "kale", "potatoes", "broth", "hardCheese"], ["Simmer diced potato in broth for 10 minutes.", "Add white beans and very finely chopped kale; simmer 10 more minutes until soft.", "Top with grated parmesan."], "Italian-Inspired", 25),
    ("Chicken & Rice Soup", ["chickenBreast", "rice", "carrots", "broth"], ["Poach chicken in broth with diced carrot for 20 minutes; shred finely.", "Add cooked rice and simmer until thick.", "Cool to warm."], "American", 30),
    ("Sweet Corn Chowder", ["corn", "potatoes", "milk", "broth", "onion"], ["Simmer diced potato and onion in broth until soft.", "Add corn and milk; blend half the soup so it's thick and creamy and no whole kernels remain loose.", "Cool to warm."], "American", 25),
    ("Broccoli Cheddar Soup", ["broccoli", "potatoes", "milk", "broth", "hardCheese"], ["Simmer broccoli and potato in broth for 15 minutes.", "Blend with milk until smooth.", "Stir in cheddar until melted."], "American", 25),
    ("Sweet Potato & Carrot Ginger Soup", ["sweetPotato", "carrots", "coconutMilk", "broth", "ginger"], ["Simmer sweet potato and carrot in broth with a slice of ginger for 20 minutes.", "Remove the ginger and blend with coconut milk.", "Cool to warm."], "Asian-Inspired", 30),
    ("Mild Chicken Tortilla Soup", ["chickenThighs", "beans", "tomatoes", "corn", "broth", "tortillas", "avocado"], ["Simmer chicken in broth with tomatoes, beans and corn for 25 minutes; shred chicken finely.", "Top with soft tortilla strips and diced avocado.", "Cool to warm."], "Mexican-Inspired", 35),
]:
    r("LD", title, mins, keys, "soft dip", steps, cuisine, batch=True)

for title, keys, steps, cuisine in [
    ("Mild Teriyaki Chicken Rice Bowl", ["chickenThighs", "rice", "broccoli", "soySauce", "honey"], ["Simmer shredded cooked chicken in a little low-sodium soy sauce and honey (12 months+) until glazed.", "Serve over soft rice with finely chopped steamed broccoli."], "Japanese-Inspired"),
    ("Salmon & Avocado Rice Bowl", ["salmon", "rice", "avocado", "cucumber", "soySauce"], ["Flake cooked salmon, checking for bones.", "Serve over rice with diced avocado, thin peeled cucumber and a drop of low-sodium soy sauce."], "Japanese-Inspired"),
    ("Crispy Tofu & Veggie Rice Bowl", ["tofu", "rice", "carrots", "edamame", "soySauce"], ["Pan-fry tofu cubes until golden; cut into small pieces.", "Serve over rice with steamed grated carrot and smashed edamame."], "Asian-Inspired"),
    ("Veggie Egg Fried Rice", ["rice", "eggs", "frozenVeg", "soySauce"], ["Scramble an egg in a pan and set aside.", "Fry cold cooked rice with mixed vegetables until hot; stir in the egg and a drop of soy sauce."], "Asian-Inspired"),
    ("Black Bean Burrito Bowl", ["beans", "rice", "corn", "avocado", "hardCheese", "salsa"], ["Warm and lightly mash black beans with corn.", "Arrange with rice, diced avocado, shredded cheese and a little mild salsa."], "Mexican-Inspired"),
    ("Greek Chicken Rice Bowl", ["chickenBreast", "rice", "cucumber", "greekYogurt", "herbs", "lemon"], ["Shred lemon-oregano chicken finely.", "Serve over rice with peeled cucumber and a dill yogurt sauce."], "Greek-Inspired"),
]:
    r("LD", title, 15, keys, "soft finger", steps, cuisine)

for title, keys, steps, cuisine, batch in [
    ("Nut-Free Spinach Pesto Pasta", ["pasta", "spinach", "herbs", "hardCheese", "oliveOil", "hempSeeds"], ["Blend spinach, basil, parmesan, olive oil and hemp seeds into a smooth pesto.", "Toss with soft-cooked pasta and a splash of pasta water."], "Italian-Inspired", False),
    ("Tomato Lentil Pasta", ["pasta", "lentils", "tomatoes", "onion"], ["Simmer red lentils in crushed tomatoes with softened onion for 20 minutes.", "Toss with soft-cooked pasta."], "Italian-Inspired", True),
    ("Creamy Chicken & Broccoli Pasta", ["pasta", "chickenBreast", "broccoli", "milk", "hardCheese"], ["Simmer milk with grated parmesan until slightly thick.", "Toss with pasta, finely shredded chicken and chopped steamed broccoli."], "Italian-Inspired", False),
    ("Tuna & Pea Pasta", ["pasta", "cannedTuna", "peas", "greekYogurt", "lemon"], ["Mix flaked tuna, peas, Greek yogurt and lemon.", "Toss with warm pasta."], "Italian-Inspired", False),
    ("Butter Noodles with Peas & Parmesan", ["eggNoodles", "butter", "peas", "hardCheese"], ["Cook egg noodles until very soft.", "Toss with butter, smashed peas and grated parmesan."], "American", False),
    ("Ricotta Spinach Stuffed Shells", ["pasta", "ricotta", "spinach", "marinara", "mozzarella"], ["Fill cooked shells with ricotta mixed with chopped spinach.", "Top with marinara and mozzarella; bake at 375°F / 190°C for 20 minutes.", "Cut shells in half to serve."], "Italian-Inspired", True),
    ("Orzo with Peas & Parmesan", ["orzo", "peas", "hardCheese", "butter", "broth"], ["Cook orzo in broth until soft and creamy.", "Stir in peas, butter and parmesan."], "Italian-Inspired", False),
    ("Creamy Avocado Pasta", ["pasta", "avocado", "lemon", "hardCheese"], ["Blend avocado, lemon and parmesan with a splash of pasta water.", "Toss with warm pasta."], "Italian-Inspired", False),
    ("Pumpkin Sage Pasta", ["pasta", "pumpkinPuree", "milk", "hardCheese", "herbs"], ["Warm pumpkin purée with milk, parmesan and a little sage.", "Toss with soft-cooked pasta."], "Italian-Inspired", False),
    ("Sardine & Tomato Pasta", ["pasta", "sardines", "tomatoes", "garlic"], ["Simmer crushed tomatoes with garlic and mashed sardines for 10 minutes.", "Toss with soft pasta."], "Mediterranean", False),
]:
    r("LD", title, 20, keys, "soft", steps, cuisine, batch)

for title, keys, step, cuisine in [
    ("Couscous with Chickpeas & Cucumber", ["couscous", "beans", "cucumber", "lemon", "oliveOil"], "Fluff couscous and mix with lightly mashed chickpeas, finely diced peeled cucumber, lemon and olive oil.", "Moroccan-Inspired"),
    ("Rainbow Quinoa Salad", ["quinoa", "bellPepper", "corn", "edamame", "oliveOil"], "Mix soft-cooked quinoa with steamed diced pepper, corn and smashed edamame.", "American"),
    ("Greek Orzo Salad", ["orzo", "cucumber", "feta", "cherryTomatoes", "oliveOil"], "Toss orzo with peeled cucumber, crumbled feta, quartered cherry tomatoes and olive oil.", "Greek-Inspired"),
    ("Rice & Bean Salad", ["rice", "beans", "corn", "avocado", "lemon"], "Toss rice with lightly mashed beans, corn, diced avocado and lemon.", "Latin American-Inspired"),
]:
    r("L", title, 15, keys, "soft finger", [step, "Serve at room temperature with a spoon or as finger-food clumps."], cuisine)

for title, keys, top in [
    ("Loaded Sweet Potato with Black Beans", ["sweetPotato", "beans", "greekYogurt", "hardCheese"], "Mash the flesh with black beans; top with cheese and Greek yogurt."),
    ("Broccoli Cheese Baked Potato", ["potatoes", "broccoli", "hardCheese", "milk"], "Mash the flesh with milk, finely chopped broccoli and cheddar."),
    ("Tuna Melt Baked Potato", ["potatoes", "cannedTuna", "hardCheese", "greekYogurt"], "Mash the flesh with tuna and Greek yogurt; top with cheese and broil 1 minute."),
    ("Chili-Topped Baked Potato", ["potatoes", "groundBeef", "beans", "tomatoes", "hardCheese"], "Top with a mild beef and bean chili and a sprinkle of cheese."),
]:
    r("LD", title, 15, keys, "soft", [
        "Microwave the potato 6–8 minutes (or bake 45 minutes) until very soft.",
        "Halve it and fluff the inside.",
        top,
        "Cool, then scoop into a bowl or serve in small pieces.",
    ])

for title, keys, prep in [
    ("Homemade Chicken Nuggets", ["chickenBreast", "eggs", "panko", "hardCheese"], "Cut chicken into small, flat strips."),
    ("Crispy Fish Nuggets", ["whiteFish", "eggs", "panko", "lemon"], "Cut fish into small strips and check for bones."),
    ("Crispy Tofu Nuggets", ["tofu", "flour", "panko", "soySauce"], "Press tofu, cut into small flat pieces and toss in a drop of soy sauce."),
    ("Veggie Nuggets", ["broccoli", "carrots", "potatoes", "hardCheese", "panko", "eggs"], "Mash steamed broccoli, carrot and potato with cheese and shape into small flat nuggets."),
    ("Turkey & Sweet Potato Nuggets", ["groundTurkey", "sweetPotato", "panko", "eggs"], "Mix ground turkey with mashed sweet potato and shape into small flat nuggets."),
]:
    r("LD", title, 25, keys + ["greekYogurt"], "finger crispy dip", [
        prep,
        "Dip in beaten egg (or flour), then coat in panko.",
        "Bake at 425°F / 220°C for 12–15 minutes, flipping halfway, until golden and cooked through.",
        "Serve with a Greek yogurt ranch dip.",
    ], batch=True)

for title, keys, step in [
    ("Veggie Pita Pizza", ["pita", "marinara", "mozzarella", "zucchini", "mushrooms"], "Top pita with marinara, mozzarella and finely diced zucchini and mushrooms."),
    ("Margherita Tortilla Pizza", ["tortillas", "marinara", "mozzarella", "herbs"], "Top a tortilla with marinara, mozzarella and torn basil."),
    ("Chicken & Spinach Flatbread", ["pita", "chickenBreast", "spinach", "mozzarella", "oliveOil"], "Brush pita with olive oil and top with shredded chicken, chopped spinach and mozzarella."),
    ("Hummus & Veggie Flatbread", ["pita", "hummus", "cucumber", "cherryTomatoes", "feta"], "Spread hummus on warm pita and top with peeled cucumber, quartered tomatoes and feta (no baking needed)."),
]:
    r("LD", title, 15, keys, "finger crispy", [
        step,
        "Bake at 400°F / 200°C for 8–10 minutes until bubbly (skip for no-bake toppings).",
        "Cool and cut into small squares.",
    ], "Italian-Inspired")

for title, keys, cuisine in [
    ("Chicken Caesar-Style Wrap", ["tortillas", "chickenBreast", "greekYogurt", "hardCheese", "spinach", "lemon"], "American"),
    ("Smashed Chickpea & Hummus Wrap", ["tortillas", "beans", "hummus", "cucumber"], "Middle Eastern-Inspired"),
    ("Turkey, Cheese & Spinach Wrap", ["tortillas", "deliTurkey", "hardCheese", "spinach"], "American"),
    ("Shrimp & Avocado Wrap", ["tortillas", "shrimp", "avocado", "greekYogurt"], "Mexican-Inspired"),
]:
    r("L", title, 10, keys, "finger", [
        f"Layer finely chopped {join(keys[1:], skip_seasonings=True)} over a warm tortilla.",
        "Roll up tightly.",
        "Slice into 1-inch pinwheels.",
    ], cuisine)

for title, keys, cuisine in [
    ("Mediterranean Snack Plate", ["hummus", "pita", "cucumber", "feta", "cherryTomatoes"], "Mediterranean"),
    ("Mexican Fiesta Plate", ["refriedBeans", "tortillas", "avocado", "hardCheese", "mandarin"], "Mexican-Inspired"),
    ("Japanese-Inspired Bento Box", ["rice", "eggs", "edamame", "cucumber", "mandarin"], "Japanese-Inspired"),
    ("Ploughman's Toddler Plate", ["hardCheese", "ham", "applesPears", "bread"], "British-Inspired"),
    ("Rainbow Veggie Plate with Hummus", ["hummus", "carrots", "bellPepper", "cucumber", "blueberries"], "American"),
    ("Brunch Plate", ["eggs", "bread", "banana", "greekYogurt", "strawberries"], "American"),
]:
    r("L", title, 10, keys, "finger dip", [
        f"Arrange {join(keys)} in separate sections of a divided plate.",
        "Prepare each item using the safety guide (steam hard veggies, quarter round foods).",
        "Include a dip to encourage tasting, and let your toddler choose what and how much to eat.",
    ], cuisine)

r("LD", "Cheesy Polenta with White Beans & Spinach", 20, ["polenta", "whiteBeans", "hardCheese", "spinach", "broth"], "soft", [
    "Cook polenta in broth until thick and creamy; stir in parmesan.",
    "Warm white beans with chopped spinach until wilted.",
    "Spoon the beans over the polenta."], "Italian-Inspired")
r("LD", "Lemon Spinach Risotto", 30, ["rice", "spinach", "lemon", "hardCheese", "broth", "butter"], "soft", [
    "Toast rice in butter, then add warm broth a ladle at a time, stirring, for 20 minutes.",
    "Stir in chopped spinach, lemon zest and parmesan.",
    "Cool to warm."], "Italian-Inspired")
r("L", "Mini Turkey Sliders", 20, ["groundTurkey", "bread", "hardCheese", "cucumber"], "finger", [
    "Shape ground turkey into small, thin patties and cook until 165°F / 74°C.",
    "Serve on small rounds of bread with a slice of cheese.",
    "Cut each slider in half; serve with thin cucumber."])
r("L", "Veggie Omelet Strips", 10, ["eggs", "bellPepper", "spinach", "hardCheese"], "finger", [
    "Soften finely chopped pepper and spinach in a pan.",
    "Add 2 whisked eggs and cheese; cook until fully set, then flip.",
    "Slice into strips."])
r("L", "Ham & Cheese Savory Crêpes", 20, ["flour", "eggs", "milk", "ham", "hardCheese"], "finger", [
    "Whisk flour, egg and milk into a thin batter and cook thin crêpes.",
    "Fill with finely diced ham and cheese and fold into quarters; warm until melted.",
    "Cut into strips."], "French-Inspired")
r("L", "Peanut Noodles with Cucumber & Edamame", 15, ["pasta", "nutButter", "soySauce", "cucumber", "edamame"], "soft", [
    "Whisk peanut butter with warm water and a drop of soy sauce into a thin, smooth sauce.",
    "Toss with soft noodles, peeled cucumber strips and smashed edamame.",
    "Serve warm or at room temperature."], "Asian-Inspired")

# ============================================================================================
# DINNER
# ============================================================================================

for title, keys, steps, cuisine in [
    ("Lemon Herb Chicken Thighs with Potatoes & Carrots", ["chickenThighs", "potatoes", "carrots", "lemon", "herbs", "oliveOil"], ["Heat the oven to 425°F / 220°C.", "Toss small potato chunks and carrot sticks with olive oil and roast 15 minutes.", "Add chicken thighs rubbed with lemon and herbs; roast 25 minutes until 165°F / 74°C.", "Shred the chicken and serve with the soft veggies."], "Mediterranean"),
    ("Maple Salmon with Sweet Potatoes & Broccoli", ["salmon", "sweetPotato", "broccoli", "mapleSyrup", "oliveOil"], ["Heat the oven to 425°F / 220°C.", "Roast sweet potato cubes with oil for 15 minutes; add broccoli.", "Add salmon brushed with a little maple syrup; roast 12 minutes until it flakes.", "Flake the salmon, checking for bones."], "American"),
    ("Parmesan-Crusted White Fish with Green Beans", ["whiteFish", "greenBeans", "hardCheese", "panko", "oliveOil", "potatoes"], ["Heat the oven to 425°F / 220°C and roast potato wedges for 15 minutes.", "Top fish with a parmesan-panko crust and add to the pan with green beans.", "Roast 12 minutes until the fish flakes; check for bones."], "American"),
    ("Crispy Sheet-Pan Tofu with Broccoli & Rice", ["tofu", "broccoli", "rice", "soySauce", "oliveOil"], ["Heat the oven to 425°F / 220°C.", "Toss pressed tofu cubes and broccoli with oil and a drop of soy sauce.", "Roast 25 minutes, flipping once, until golden.", "Serve over soft rice; cut tofu small."], "Asian-Inspired"),
    ("Sheet-Pan Turkey Meatballs with Zucchini", ["groundTurkey", "zucchini", "panko", "eggs", "oliveOil", "couscous"], ["Heat the oven to 400°F / 200°C.", "Mix turkey, panko and egg; shape small flattened meatballs.", "Roast with zucchini half-moons for 18 minutes until cooked through.", "Serve with fluffy couscous."], "Mediterranean"),
    ("Chicken Sausage with Peppers & Potatoes", ["chickenSausage", "bellPepper", "potatoes", "oliveOil"], ["Heat the oven to 425°F / 220°C.", "Roast potato chunks and pepper strips with oil for 20 minutes.", "Add sausage and roast 12 minutes more.", "Quarter the sausage lengthwise, then chop small — never serve coins."], "American"),
    ("Pork Tenderloin with Apples & Butternut Squash", ["porkTenderloin", "applesPears", "butternutSquash", "oliveOil"], ["Heat the oven to 425°F / 220°C.", "Roast squash cubes and apple wedges with oil for 15 minutes.", "Add pork tenderloin and roast 20 minutes to 145°F / 63°C; rest 5 minutes.", "Slice pork very thin and chop small."], "American"),
    ("Chickpea & Cauliflower Sheet Pan with Yogurt", ["beans", "cauliflower", "sweetPotato", "oliveOil", "spices", "greekYogurt"], ["Heat the oven to 425°F / 220°C.", "Toss chickpeas, cauliflower and sweet potato with oil and mild spices.", "Roast 25 minutes until soft.", "Lightly mash the chickpeas and serve with Greek yogurt."], "Middle Eastern-Inspired"),
    ("Sheet-Pan Shrimp & Veggies with Rice", ["shrimp", "zucchini", "bellPepper", "rice", "oliveOil"], ["Heat the oven to 425°F / 220°C.", "Roast zucchini and pepper with oil for 12 minutes.", "Add shrimp and roast 6–8 minutes until pink.", "Chop shrimp small and serve over rice."], "American"),
]:
    r("D", title, 40, keys, "soft finger", steps, cuisine)

for title, keys, steps in [
    ("Chicken & Veggie Stir-Fry", ["chickenBreast", "broccoli", "carrots", "rice", "soySauce", "garlic"], ["Stir-fry thin chicken strips with garlic until cooked through.", "Add finely chopped broccoli and grated carrot with a splash of water; cover and steam until soft.", "Season with a drop of soy sauce and serve over rice, chopping the chicken small."]),
    ("Ground Beef & Broccoli Stir-Fry", ["groundBeef", "broccoli", "rice", "soySauce", "ginger"], ["Brown ground beef with grated ginger, breaking it into fine crumbles.", "Add small broccoli florets and a splash of water; cover until soft.", "Season lightly with soy sauce and serve over rice."]),
    ("Tofu & Pea Stir-Fry", ["tofu", "peas", "carrots", "rice", "soySauce"], ["Pan-fry tofu cubes until golden.", "Add peas and grated carrot; cook until soft.", "Season with a drop of soy sauce and serve over rice."]),
    ("Shrimp & Pea Fried Rice", ["shrimp", "rice", "peas", "eggs", "soySauce"], ["Scramble an egg and set aside.", "Stir-fry finely chopped shrimp until pink, then add cold rice and peas.", "Stir in the egg and a drop of soy sauce."]),
    ("Sweet & Sour Pork with Pineapple", ["porkTenderloin", "pineappleMelon", "bellPepper", "rice", "soySauce"], ["Stir-fry thin pork strips until cooked through.", "Add diced pineapple and pepper with a splash of pineapple juice and soy sauce; simmer until soft.", "Chop small and serve over rice."]),
    ("Veggie Lo Mein with Egg Noodles", ["eggNoodles", "carrots", "zucchini", "mushrooms", "soySauce", "eggs"], ["Cook egg noodles until soft.", "Stir-fry grated carrot, zucchini and chopped mushrooms; add a scrambled egg.", "Toss with noodles and a drop of soy sauce; cut noodles short."]),
]:
    r("D", title, 25, keys, "soft finger", steps, "Asian-Inspired")

for title, keys, steps, cuisine in [
    ("Mild Chicken Korma", ["chickenThighs", "greekYogurt", "onion", "curryPowder", "rice", "coconutMilk"], ["Soften onion, then add chicken pieces and mild curry powder.", "Simmer in coconut milk for 25 minutes until tender; stir in Greek yogurt off the heat.", "Shred the chicken and serve over rice."], "Indian-Inspired"),
    ("Chickpea & Spinach Curry", ["beans", "spinach", "coconutMilk", "tomatoes", "curryPowder", "rice"], ["Simmer chickpeas in tomatoes, coconut milk and mild curry powder for 15 minutes.", "Stir in chopped spinach until wilted; mash some chickpeas.", "Serve over rice."], "Indian-Inspired"),
    ("Red Lentil Dal with Rice", ["lentils", "tomatoes", "onion", "curryPowder", "rice", "butter"], ["Simmer red lentils with onion, tomatoes and mild curry powder for 20 minutes until thick.", "Stir in a little butter.", "Serve over soft rice."], "Indian-Inspired"),
    ("Coconut Fish Curry", ["whiteFish", "coconutMilk", "tomatoes", "curryPowder", "rice"], ["Simmer coconut milk, tomatoes and mild curry powder for 10 minutes.", "Add fish pieces and poach 6–8 minutes until flaky; check for bones.", "Serve over rice."], "Indian-Inspired"),
    ("Sweet Potato & Chickpea Curry", ["sweetPotato", "beans", "coconutMilk", "curryPowder", "rice"], ["Simmer sweet potato cubes in coconut milk with mild curry powder for 15 minutes.", "Add chickpeas and cook until everything is very soft.", "Mash lightly and serve over rice."], "Indian-Inspired"),
    ("Butternut Squash & Lentil Curry", ["butternutSquash", "lentils", "coconutMilk", "curryPowder", "rice"], ["Simmer squash and red lentils in coconut milk and water with mild curry powder for 25 minutes.", "Mash to a thick, soft stew.", "Serve over rice."], "Indian-Inspired"),
    ("Japanese Chicken Curry", ["chickenThighs", "potatoes", "carrots", "onion", "curryPowder", "rice"], ["Soften onion, then add chicken, potato and carrot chunks.", "Cover with water and mild curry powder; simmer 25 minutes until thick and soft.", "Shred the chicken and serve over rice."], "Japanese-Inspired"),
]:
    r("D", title, 35, keys, "soft", steps, cuisine, batch=True)

for title, keys, steps, cuisine in [
    ("Beef Lasagna Roll-Ups", ["pasta", "groundBeef", "ricotta", "marinara", "mozzarella"], ["Brown ground beef finely and mix with marinara.", "Spread ricotta on cooked lasagna noodles, add beef sauce and roll up.", "Top with sauce and mozzarella; bake at 375°F / 190°C for 25 minutes.", "Slice each roll-up into rounds."], "Italian-Inspired"),
    ("Chicken, Spinach & Ricotta Pasta Bake", ["pasta", "chickenBreast", "spinach", "ricotta", "marinara", "mozzarella"], ["Toss cooked pasta with shredded chicken, spinach, ricotta and marinara.", "Top with mozzarella and bake at 375°F / 190°C for 20 minutes."], "Italian-Inspired"),
    ("Sausage & Kale Pasta Bake", ["pasta", "chickenSausage", "kale", "marinara", "mozzarella"], ["Brown sausage (casing removed) into fine crumbles with finely chopped kale.", "Toss with pasta and marinara, top with mozzarella and bake 20 minutes."], "Italian-Inspired"),
    ("Tuna Noodle Casserole", ["eggNoodles", "cannedTuna", "peas", "milk", "hardCheese", "flour", "butter"], ["Make a simple cheese sauce with butter, flour, milk and cheddar.", "Fold in noodles, flaked tuna and peas.", "Bake at 375°F / 190°C for 20 minutes."], "American"),
    ("Lentil Bolognese", ["lentils", "pasta", "carrots", "tomatoes", "onion", "hardCheese"], ["Simmer brown lentils with grated carrot, onion and crushed tomatoes for 30 minutes.", "Toss with soft pasta and top with parmesan."], "Italian-Inspired"),
    ("Salmon & Pea Pasta Bake", ["pasta", "salmon", "peas", "milk", "hardCheese", "flour"], ["Make a light cheese sauce.", "Fold in pasta, flaked salmon (bones removed) and peas.", "Bake at 375°F / 190°C for 20 minutes."], "American"),
    ("Baked Ziti with Turkey", ["pasta", "groundTurkey", "marinara", "ricotta", "mozzarella"], ["Brown ground turkey finely and simmer with marinara.", "Layer with pasta and dollops of ricotta; top with mozzarella.", "Bake at 375°F / 190°C for 25 minutes."], "Italian-Inspired"),
    ("Veggie Lasagna", ["pasta", "spinach", "zucchini", "ricotta", "marinara", "mozzarella"], ["Layer lasagna noodles with marinara, ricotta, chopped spinach and grated zucchini.", "Top with mozzarella and bake covered at 375°F / 190°C for 40 minutes.", "Rest 10 minutes before cutting small squares."], "Italian-Inspired"),
]:
    r("D", title, 45, keys, "soft", steps, cuisine, batch=True)

for title, keys, filling in [
    ("Shredded Chicken Soft Tacos", ["chickenThighs", "tortillas", "avocado", "hardCheese", "spices"], "Simmer chicken thighs with mild spices until tender and shred finely."),
    ("Flaky Fish Tacos with Yogurt Sauce", ["whiteFish", "tortillas", "greekYogurt", "lemon", "avocado"], "Bake seasoned fish 10 minutes and flake, checking for bones; stir lemon into Greek yogurt."),
    ("Mild Beef Soft Tacos", ["groundBeef", "tortillas", "tomatoes", "hardCheese", "spices", "greekYogurt"], "Brown ground beef finely with crushed tomatoes and mild spices."),
    ("Black Bean & Sweet Potato Tacos", ["beans", "sweetPotato", "tortillas", "avocado", "feta"], "Mash roasted sweet potato with warm black beans."),
    ("Pulled Pork Tacos with Mango", ["porkShoulder", "tortillas", "mangoPeach", "greekYogurt"], "Use slow-cooked, finely pulled pork and diced ripe mango."),
    ("Shrimp & Corn Tacos", ["shrimp", "corn", "tortillas", "avocado"], "Sauté finely chopped shrimp with corn until pink and cooked."),
    ("Lentil Tacos", ["lentils", "tortillas", "tomatoes", "spices", "hardCheese", "avocado"], "Simmer brown lentils with crushed tomatoes and mild spices until thick."),
    ("Turkey Taco Rice Bowls", ["groundTurkey", "rice", "beans", "corn", "hardCheese", "salsa"], "Brown ground turkey finely with mild spices and a little salsa."),
]:
    r("D", title, 25, keys, "finger soft", [
        filling,
        "Warm soft tortillas (or rice) and add the filling with soft toppings.",
        "For little ones, serve deconstructed or cut tacos into strips.",
    ], "Mexican-Inspired")

for title, keys, steps, cuisine in [
    ("Turkey Meatballs in Marinara with Spaghetti", ["groundTurkey", "panko", "eggs", "hardCheese", "marinara", "pasta"], ["Mix turkey, panko, egg and parmesan; shape small flattened meatballs.", "Simmer in marinara for 15 minutes until cooked through.", "Serve with spaghetti cut short; halve the meatballs."], "Italian-Inspired"),
    ("Swedish Meatballs with Egg Noodles", ["groundBeef", "groundPork", "panko", "eggs", "broth", "greekYogurt", "eggNoodles"], ["Mix beef, pork, panko and egg; shape small meatballs and brown.", "Simmer in broth 10 minutes; stir in Greek yogurt off the heat for a creamy sauce.", "Serve over soft egg noodles; halve meatballs."], "Scandinavian-Inspired"),
    ("Chicken Spinach Meatballs with Orzo", ["groundChicken", "spinach", "panko", "eggs", "orzo", "broth"], ["Mix chicken, chopped spinach, panko and egg; shape small meatballs.", "Bake at 400°F / 200°C for 15 minutes.", "Serve with orzo cooked in broth."], "Mediterranean"),
    ("Mild Lamb Kofta with Yogurt & Couscous", ["groundLamb", "onion", "spices", "greekYogurt", "couscous", "cucumber"], ["Mix lamb with grated onion and mild cumin; shape small flat patties.", "Pan-cook until cooked through (160°F / 71°C).", "Serve with couscous and a cucumber yogurt sauce."], "Middle Eastern-Inspired"),
    ("Moroccan Beef Meatballs with Couscous", ["groundBeef", "spices", "tomatoes", "couscous", "carrots"], ["Mix beef with mild cumin and cinnamon; shape small meatballs.", "Simmer in crushed tomatoes with grated carrot for 20 minutes.", "Serve over couscous."], "Moroccan-Inspired"),
    ("Pork & Apple Meatballs with Mash", ["groundPork", "applesPears", "panko", "eggs", "potatoes", "milk"], ["Mix pork with grated apple, panko and egg; shape small meatballs.", "Bake at 400°F / 200°C for 18 minutes.", "Serve with creamy mashed potatoes."], "British-Inspired"),
]:
    r("D", title, 35, keys, "soft finger", steps, cuisine, batch=True)

for title, keys, steps, cuisine, mins in [
    ("Beef & Sweet Potato Stew", ["beefChuck", "sweetPotato", "carrots", "broth", "onion", "tomatoes"], ["Brown beef chunks, then add onion, tomatoes and broth.", "Simmer covered 1½ hours; add sweet potato and carrot for the last 30 minutes.", "Shred the beef finely and mash veggies slightly."], "American", 120),
    ("Chicken & White Bean Stew", ["chickenThighs", "whiteBeans", "carrots", "spinach", "broth"], ["Simmer chicken thighs with carrot in broth for 25 minutes.", "Shred chicken, add white beans and spinach; simmer 10 minutes.", "Mash a few beans to thicken."], "Italian-Inspired", 40),
    ("Pork & Apple Braise with Mash", ["porkShoulder", "applesPears", "onion", "broth", "potatoes"], ["Brown pork, add sliced apple, onion and broth.", "Braise covered at 325°F / 165°C for 2½ hours until it pulls apart.", "Shred finely and serve with mashed potatoes."], "British-Inspired", 160),
    ("Chickpea & Vegetable Tagine", ["beans", "sweetPotato", "carrots", "tomatoes", "spices", "couscous"], ["Simmer chickpeas, sweet potato and carrot in tomatoes with mild cumin and cinnamon for 25 minutes.", "Mash lightly.", "Serve over couscous."], "Moroccan-Inspired", 35),
    ("Mild Lamb Keema with Peas & Rice", ["groundLamb", "peas", "tomatoes", "curryPowder", "rice"], ["Brown ground lamb finely with mild curry powder.", "Simmer with crushed tomatoes and peas for 15 minutes.", "Serve over rice."], "Indian-Inspired", 30),
    ("Chicken Cacciatore with Polenta", ["chickenThighs", "tomatoes", "bellPepper", "mushrooms", "polenta"], ["Brown chicken thighs; add tomatoes, peppers and mushrooms.", "Simmer covered 35 minutes; shred chicken finely.", "Serve over soft polenta."], "Italian-Inspired", 50),
    ("Slow-Cooker Beef Ragù with Pasta", ["beefChuck", "tomatoes", "carrots", "pasta", "hardCheese"], ["Slow-cook beef with crushed tomatoes and grated carrot on low for 8 hours.", "Shred the beef very finely into the sauce.", "Toss with soft pasta and parmesan."], "Italian-Inspired", 480),
    ("Brazilian-Style Black Bean Stew", ["beans", "sweetPotato", "bellPepper", "rice", "spices", "mandarin"], ["Simmer black beans with sweet potato, pepper and mild spices for 25 minutes.", "Mash to a thick stew.", "Serve with rice and mandarin segments on the side."], "Latin American-Inspired", 35),
]:
    r("D", title, mins, keys, "soft", steps, cuisine, batch=True)

for title, keys, steps, cuisine in [
    ("Baked Cod with Lemon Butter & Rice", ["whiteFish", "butter", "lemon", "rice", "peas"], ["Bake cod with lemon and a little butter at 400°F / 200°C for 12 minutes.", "Flake and check for bones.", "Serve with rice and peas."], "American"),
    ("Salmon Teriyaki with Rice & Edamame", ["salmon", "soySauce", "honey", "rice", "edamame"], ["Brush salmon with low-sodium soy sauce and honey (12 months+).", "Bake 12 minutes; flake and check for bones.", "Serve with rice and smashed edamame."], "Japanese-Inspired"),
    ("Cozy Fish Pie with Mash Topping", ["whiteFish", "salmon", "potatoes", "milk", "peas", "butter"], ["Poach fish in milk, then flake and check for bones.", "Mix with peas and a little of the milk; top with mashed potato.", "Bake at 400°F / 200°C for 20 minutes."], "British-Inspired"),
    ("Creamy White Fish Chowder", ["whiteFish", "potatoes", "corn", "milk", "broth"], ["Simmer diced potato in broth until soft.", "Add milk, corn and fish pieces; simmer 6 minutes until flaky.", "Blend a little for thickness and check for bones."], "American"),
    ("Poached Salmon with Dill Yogurt & Potatoes", ["salmon", "potatoes", "greekYogurt", "herbs", "greenBeans"], ["Poach salmon in simmering water for 10 minutes; flake and check for bones.", "Serve with boiled potatoes and soft green beans.", "Top with Greek yogurt mixed with dill."], "Scandinavian-Inspired"),
    ("Mediterranean Baked Fish with Tomatoes & Couscous", ["whiteFish", "cherryTomatoes", "oliveOil", "couscous", "zucchini"], ["Bake fish with quartered cherry tomatoes, zucchini and olive oil at 400°F / 200°C for 15 minutes.", "Flake the fish and check for bones.", "Serve over couscous."], "Mediterranean"),
]:
    r("D", title, 30, keys, "soft finger", steps, cuisine)

for title, keys, steps, cuisine, mins, batch in [
    ("Lemon Herb Shredded Chicken with Rice & Peas", ["chickenThighs", "lemon", "herbs", "rice", "peas"], ["Bake chicken thighs with lemon and herbs for 30 minutes until 165°F / 74°C.", "Shred finely.", "Serve with rice and peas."], "Mediterranean", 35, False),
    ("Honey Garlic Chicken with Rice", ["chickenThighs", "honey", "garlic", "soySauce", "rice", "broccoli"], ["Simmer chicken pieces in honey (12 months+), garlic and a little soy sauce until tender.", "Shred and serve over rice with soft broccoli."], "Asian-Inspired", 30, False),
    ("Chicken Parmesan Bites with Spaghetti", ["chickenBreast", "panko", "hardCheese", "eggs", "marinara", "pasta", "mozzarella"], ["Cut chicken into small flat pieces, coat in egg and parmesan-panko.", "Bake at 425°F / 220°C for 12 minutes, top with marinara and mozzarella, and bake 3 more minutes.", "Serve with short spaghetti."], "Italian-Inspired", 30, False),
    ("Mini Chicken Pot Pies", ["chickenThighs", "frozenVeg", "milk", "flour", "butter", "broth"], ["Make a creamy sauce with butter, flour, broth and milk; stir in shredded chicken and mixed veg.", "Spoon into ramekins and top with a simple biscuit dough (flour, butter, milk).", "Bake at 400°F / 200°C for 20 minutes."], "American", 45, True),
    ("Cheesy Chicken & Rice Casserole", ["chickenBreast", "rice", "broccoli", "milk", "hardCheese"], ["Mix cooked rice, shredded chicken, chopped broccoli, milk and cheddar.", "Bake at 375°F / 190°C for 25 minutes until bubbly."], "American", 35, True),
    ("Mild Chicken Shawarma Bowls", ["chickenThighs", "spices", "greekYogurt", "rice", "cucumber", "pita"], ["Marinate chicken in Greek yogurt and mild spices; bake 25 minutes.", "Shred finely.", "Serve with rice, peeled cucumber, yogurt sauce and soft pita strips."], "Middle Eastern-Inspired", 35, False),
    ("Mild Butter Chicken with Rice", ["chickenThighs", "tomatoes", "butter", "greekYogurt", "curryPowder", "rice"], ["Simmer chicken pieces in tomatoes, butter and mild curry powder for 25 minutes.", "Stir in Greek yogurt off the heat.", "Shred and serve over rice."], "Indian-Inspired", 35, True),
    ("Spanish-Style Chicken & Rice", ["chickenThighs", "rice", "bellPepper", "peas", "tomatoes", "spices"], ["Brown chicken pieces, then add rice, tomatoes, peppers and mild paprika with water.", "Cover and simmer 25 minutes; add peas at the end.", "Shred chicken into the rice."], "Latin American-Inspired", 40, True),
]:
    r("D", title, mins, keys, "soft finger", steps, cuisine, batch)

for title, keys, steps, cuisine, mins, batch in [
    ("Shepherd's Pie", ["groundLamb", "frozenVeg", "potatoes", "milk", "broth"], ["Brown lamb finely with mixed veg and a splash of broth.", "Top with creamy mashed potato.", "Bake at 400°F / 200°C for 20 minutes until golden."], "British-Inspired", 50, True),
    ("Mild Beef Stroganoff", ["groundBeef", "mushrooms", "onion", "greekYogurt", "eggNoodles", "broth"], ["Brown ground beef with finely chopped mushrooms and onion.", "Simmer with broth, then stir in Greek yogurt off the heat.", "Serve over soft egg noodles."], "Scandinavian-Inspired", 25, False),
    ("Pot Roast with Root Veggies", ["beefChuck", "potatoes", "carrots", "onion", "broth"], ["Brown beef, then add broth, onion, potatoes and carrots.", "Braise covered at 325°F / 165°C for 3 hours until fork-tender.", "Shred the beef finely and mash veggies slightly."], "American", 200, True),
    ("Sloppy Joe Sliders", ["groundBeef", "tomatoes", "bellPepper", "onion", "bread"], ["Brown ground beef finely with diced pepper and onion.", "Simmer with crushed tomatoes until thick.", "Serve on small bread rounds, open-faced, cut in half."], "American", 25, True),
    ("Mini Meatloaf Muffins", ["groundBeef", "oats", "eggs", "carrots", "marinara", "potatoes"], ["Mix beef, oats, egg and grated carrot; press into a muffin tin.", "Top with marinara and bake at 375°F / 190°C for 20 minutes.", "Serve with mashed potatoes."], "American", 35, True),
    ("Mild Beef & Bean Chili", ["groundBeef", "beans", "tomatoes", "bellPepper", "spices", "hardCheese", "greekYogurt"], ["Brown beef finely with diced pepper.", "Simmer with beans, tomatoes and mild spices for 25 minutes; mash some beans.", "Top with cheese and Greek yogurt."], "Mexican-Inspired", 40, True),
    ("Beef & Veggie Fried Rice", ["groundBeef", "rice", "frozenVeg", "eggs", "soySauce"], ["Brown beef finely and set aside.", "Stir-fry cold rice with mixed veg and a scrambled egg.", "Stir in the beef and a drop of soy sauce."], "Asian-Inspired", 20, False),
    ("Mild Korean-Style Beef Bowl", ["groundBeef", "soySauce", "applesPears", "garlic", "rice", "cucumber"], ["Brown ground beef with garlic and finely grated pear.", "Season with a little low-sodium soy sauce.", "Serve over rice with peeled cucumber."], "Korean-Inspired", 20, False),
]:
    r("D", title, mins, keys, "soft", steps, cuisine, batch)

for title, keys, steps, cuisine, mins, batch in [
    ("Slow-Cooker Pulled Pork with Sweet Potato Mash", ["porkShoulder", "appleSauce", "spices", "sweetPotato", "greenBeans"], ["Slow-cook pork with applesauce and mild paprika on low for 8 hours.", "Pull apart very finely.", "Serve with mashed sweet potato and soft green beans."], "American", 480, True),
    ("Pork Medallions with Applesauce & Potatoes", ["porkTenderloin", "appleSauce", "potatoes", "greenBeans"], ["Sear thin pork medallions until cooked to 145°F / 63°C; rest and chop small.", "Serve with warm applesauce, roasted potatoes and green beans."], "American", 30, False),
    ("Pork & Ginger Noodle Bowl", ["groundPork", "ginger", "eggNoodles", "spinach", "soySauce", "broth"], ["Brown pork finely with grated ginger.", "Add broth, noodles and spinach; simmer until soft.", "Season lightly with soy sauce; cut noodles short."], "Asian-Inspired", 25, False),
    ("Ham & Pea Risotto", ["rice", "ham", "peas", "hardCheese", "broth", "butter"], ["Toast rice in butter and add broth gradually, stirring, for 20 minutes.", "Stir in finely diced ham, peas and parmesan."], "Italian-Inspired", 30, False),
]:
    r("D", title, mins, keys, "soft", steps, cuisine, batch)

for title, keys, steps, cuisine, mins, tex in [
    ("Black Bean Enchiladas", ["tortillas", "beans", "hardCheese", "tomatoes", "spices", "sweetPotato"], ["Fill tortillas with mashed black beans, sweet potato and cheese; roll up.", "Cover with mildly spiced tomato sauce and more cheese.", "Bake at 375°F / 190°C for 20 minutes; cut into small pieces."], "Mexican-Inspired", 40, "soft"),
    ("Crispy Tofu Katsu with Rice", ["tofu", "panko", "eggs", "rice", "carrots"], ["Slice pressed tofu into slabs, dip in egg and panko.", "Bake at 425°F / 220°C for 20 minutes until crisp.", "Cut into strips; serve with rice and steamed carrot."], "Japanese-Inspired", 30, "finger crispy"),
    ("Lentil Shepherd's Pie", ["lentils", "carrots", "peas", "potatoes", "milk", "tomatoes"], ["Simmer brown lentils with carrot, peas and tomatoes until thick.", "Top with mashed potato.", "Bake at 400°F / 200°C for 20 minutes."], "British-Inspired", 50, "soft"),
    ("Veggie Quinoa Chili", ["quinoa", "beans", "tomatoes", "corn", "bellPepper", "spices"], ["Simmer quinoa, beans, tomatoes, corn and pepper with mild spices for 25 minutes.", "Mash some beans to thicken."], "Mexican-Inspired", 35, "soft"),
    ("Creamy Mushroom Risotto", ["rice", "mushrooms", "hardCheese", "broth", "butter", "onion"], ["Soften finely chopped onion and mushrooms in butter.", "Add rice and broth gradually, stirring, for 20 minutes.", "Stir in parmesan."], "Italian-Inspired", 35, "soft"),
    ("Bean & Cheese Burritos", ["tortillas", "refriedBeans", "rice", "hardCheese", "salsa"], ["Fill tortillas with refried beans, rice and cheese.", "Roll and toast seam-side down until golden.", "Cut into 1-inch rounds; serve with mild salsa."], "Mexican-Inspired", 15, "finger"),
    ("Mild Kitchari", ["lentils", "rice", "carrots", "spices", "butter"], ["Simmer red lentils and rice with diced carrot and a pinch of turmeric for 30 minutes until porridge-like.", "Stir in a little butter."], "Indian-Inspired", 35, "soft"),
    ("Cauliflower Cheese Bake", ["cauliflower", "milk", "hardCheese", "flour", "butter", "bread"], ["Steam cauliflower until very soft.", "Cover with cheese sauce and bake at 400°F / 200°C for 15 minutes.", "Serve with toast fingers."], "British-Inspired", 30, "soft"),
    ("Ricotta Gnudi with Tomato Sauce", ["ricotta", "flour", "eggs", "hardCheese", "marinara"], ["Mix ricotta, egg, parmesan and a little flour into a soft dough.", "Shape small dumplings and simmer 3–4 minutes until they float.", "Serve with warm marinara."], "Italian-Inspired", 30, "soft"),
    ("Spanakopita-Style Tortilla Bake", ["tortillas", "spinach", "feta", "eggs", "ricotta"], ["Mix chopped spinach, feta, ricotta and egg.", "Layer between tortillas in a baking dish.", "Bake at 375°F / 190°C for 20 minutes; cut into small squares."], "Greek-Inspired", 35, "finger"),
    ("Black Bean Burgers", ["beans", "oats", "eggs", "spices", "bread", "avocado"], ["Mash black beans with oats, egg and mild spices; shape small flat patties.", "Bake at 400°F / 200°C for 18 minutes.", "Serve on bread rounds with mashed avocado, cut in half."], "American", 30, "finger"),
]:
    r("D", title, mins, keys, tex, steps, cuisine, batch=True)

for entry in [
    ("Tofu Bibimbap with Egg", ["rice", "eggs", "spinach", "carrots", "tofu", "soySauce"], ["Arrange rice with sautéed spinach, grated carrot and pan-fried tofu.", "Top with a fully cooked fried egg cut into strips.", "Add a drop of low-sodium soy sauce and mix."], "Korean-Inspired", 25),
    ("Greek Lemon Chicken Orzo", ["chickenThighs", "orzo", "lemon", "spinach", "feta", "broth"], ["Brown chicken pieces, then simmer with orzo, broth and lemon for 15 minutes.", "Stir in spinach and crumbled feta.", "Shred the chicken into the orzo."], "Greek-Inspired", 30),
    ("Caribbean Rice & Peas with Chicken", ["chickenThighs", "rice", "beans", "coconutMilk", "spices"], ["Simmer rice and kidney beans in coconut milk and water with mild thyme and allspice.", "Bake chicken thighs alongside; shred finely.", "Serve together."], "Caribbean-Inspired", 40),
    ("Moroccan Chicken & Couscous", ["chickenThighs", "couscous", "carrots", "spices", "lemon"], ["Simmer chicken with carrots, mild cumin and cinnamon for 25 minutes.", "Shred chicken and serve over couscous with a squeeze of lemon."], "Moroccan-Inspired", 35),
    ("Chicken Piccata Strips with Pasta", ["chickenBreast", "lemon", "butter", "broth", "pasta", "flour"], ["Pound chicken thin, dust in flour and pan-cook until done.", "Make a quick lemon-butter sauce with broth.", "Cut chicken into thin strips and serve with pasta."], "Italian-Inspired"),
    ("Jamaican-Style Mild Beef Patties", ["groundBeef", "flour", "butter", "curryPowder", "spices"], ["Cook ground beef finely with mild curry powder and thyme.", "Wrap in a simple pastry (flour, butter, water) and crimp.", "Bake at 400°F / 200°C for 25 minutes; cut into strips."], "Caribbean-Inspired", 50),
    ("Steamed Egg Custard with Rice", ["eggs", "broth", "rice", "peas"], ["Whisk 2 eggs with ¾ cup warm broth and strain.", "Steam gently for 12 minutes until silky and set.", "Serve with soft rice and smashed peas."], "Asian-Inspired", 20),
    ("Mild Chicken Noodle Pho", ["chickenThighs", "broth", "eggNoodles", "ginger", "herbs"], ["Simmer chicken in broth with ginger for 25 minutes; shred finely.", "Cook noodles in the broth and cut them short.", "Top with a little fresh herbs."], "Vietnamese-Inspired", 35),
    ("Peruvian-Style Chicken & Potatoes", ["chickenThighs", "potatoes", "spices", "lemon", "greekYogurt"], ["Rub chicken with mild paprika, cumin and lemon; roast with potato wedges for 35 minutes.", "Shred chicken and serve with a lemony yogurt sauce."], "Latin American-Inspired", 45),
    ("Mild Chicken Adobo", ["chickenThighs", "soySauce", "garlic", "rice", "greenBeans"], ["Simmer chicken in water with a little soy sauce, garlic and a bay leaf for 30 minutes.", "Shred finely and spoon sauce over rice.", "Serve with soft green beans."], "Filipino-Inspired", 40),
    ("Hawaiian Chicken & Pineapple Rice", ["chickenThighs", "pineappleMelon", "rice", "bellPepper", "soySauce"], ["Cook diced chicken with pineapple and pepper until tender.", "Toss with rice and a drop of soy sauce.", "Chop everything small."], "Hawaiian-Inspired"),
    ("German Potato Pancakes with Applesauce", ["potatoes", "eggs", "flour", "appleSauce", "greekYogurt"], ["Grate and squeeze potatoes; mix with egg and flour.", "Pan-fry small, thin pancakes until golden and cooked through.", "Serve with applesauce and Greek yogurt."], "German-Inspired"),
    ("Ratatouille with White Beans", ["zucchini", "bellPepper", "tomatoes", "whiteBeans", "oliveOil", "bread"], ["Simmer diced zucchini and pepper in tomatoes and olive oil for 30 minutes until very soft.", "Stir in white beans.", "Serve with toast for dipping."], "French-Inspired"),
    ("Moussaka-Style Lamb & Potato Bake", ["groundLamb", "potatoes", "tomatoes", "milk", "hardCheese"], ["Brown lamb finely and simmer with tomatoes.", "Layer with thin cooked potato slices and top with a cheesy white sauce.", "Bake at 375°F / 190°C for 30 minutes."], "Greek-Inspired", 60),
    ("Spanish Potato Tortilla", ["potatoes", "eggs", "onion", "oliveOil"], ["Gently cook thin potato and onion slices in olive oil until very soft.", "Add 4 beaten eggs and cook low until set; flip to finish.", "Cut into fingers."], "Spanish-Inspired"),
]:
    title, keys, steps, cuisine = entry[:4]
    mins = entry[4] if len(entry) > 4 else 30
    r("D", title, mins, keys, "soft finger", steps, cuisine, batch=True)

r("D", "Cheesy Spinach Waffles & Eggs", 25, ["flour", "eggs", "milk", "hardCheese", "spinach", "bakingPowder"], "finger crispy", [
    "Whisk flour, eggs, milk, baking powder, shredded cheese and chopped spinach into a batter.",
    "Cook in a waffle iron until golden.",
    "Serve in strips with a soft-scrambled egg."])
r("D", "Breakfast-for-Dinner Hash", 25, ["potatoes", "chickenSausage", "eggs", "bellPepper"], "soft finger", [
    "Pan-fry small potato cubes until soft and golden.",
    "Add crumbled sausage (casing removed) and diced pepper; cook through.",
    "Top with a fully cooked egg, chopped."])
