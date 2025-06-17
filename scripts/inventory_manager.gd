extends Node

const inventory_ui_class = preload("res://scripts/ui/inventory_ui.gd")

@onready var gold: int = 100
## key: string (ingredient name) = int (amount of increments in inventory)
@onready var inventory: Dictionary = {"Blue Leaf": 100}
@onready var ingredient_table := IngredientDataTable.factory()
var inventory_ui: inventory_ui_class
var gold_display: RichTextLabel

func _ready() -> void:
    if get_tree().current_scene is not MainScene:
        gold_display = get_tree().current_scene.get_node("CurrentGold") as RichTextLabel
    # var _a = ((ingredient_table.data["Blue Leaf"] as PackedScene).get_state().get_script() as Ingredient).composition

func add_to_inventory(ingredient_name: String, amount: int) -> void:
    if ingredient_name in inventory:
        inventory[ingredient_name] += amount
    else:
        inventory[ingredient_name] = amount
    inventory_ui.update()

func remove_from_inventory(ingredient_name: String, amount: int) -> void:
    if ingredient_name not in inventory:
        printerr("%s wasn't in inventory" % [ingredient_name])
        return
    if inventory[ingredient_name] < amount:
        printerr("Not enough %s in inventory - %d to be removed, %d in inventory" % [ingredient_name, amount, inventory[ingredient_name]])
        return

    if inventory[ingredient_name] == amount:
        inventory.erase(ingredient_name)
        inventory_ui.update()
        return

    inventory[ingredient_name] -= amount
    inventory_ui.update()

func add_gold(amount: int) -> void:
    gold += amount
    if gold_display:
        gold_display.text = "[right]Current gold: %d[/right]" % [gold]

func remove_gold(amount: int) -> void:
    gold -= amount
    if gold_display:
        gold_display.text = "[right]Current gold: %d[/right]" % [gold]
