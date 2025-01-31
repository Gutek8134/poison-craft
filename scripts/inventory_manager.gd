extends Node

@onready var gold: int = 100
## key: string (ingredient name) = int (amount in inventory)
@onready var inventory: Dictionary = {}
@onready var ingredient_table := IngredientDataTable.factory()

# func _ready() -> void:
# 	var _a = ((ingredient_table.data["Blue Leaf"] as PackedScene).get_state().get_script() as Ingredient).composition

func add_to_inventory(ingredient_name: String, amount: int) -> void:
    if ingredient_name in inventory:
        inventory[ingredient_name] += amount
    else:
        inventory[ingredient_name] = amount
    print(inventory)

func remove_from_inventory(ingredient_name: String, amount: int) -> void:
    if ingredient_name not in inventory:
        printerr("%s wasn't in inventory" % [ingredient_name])
        return
    if inventory[ingredient_name] < amount:
        printerr("Not enough %s in inventory - %d to be removed, %d in inventory" % [ingredient_name, amount, inventory[ingredient_name]])
        return

    if inventory[ingredient_name] == amount:
        inventory.erase(ingredient_name)
        print(inventory)
        return

    inventory[ingredient_name] -= amount
    print(inventory)

func add_gold(amount: int):
    gold += amount
    print(gold)

func remove_gold(amount: int):
    gold -= amount
    print(gold)
