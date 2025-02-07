extends Control

const inventory_item_scene: PackedScene = preload("res://scenes/prefabs/ui/inventory_item.tscn") as PackedScene
const slider_scene: PackedScene = preload("res://scenes/prefabs/ui/split_slider.tscn") as PackedScene
var ingredient_data_table = IngredientDataTable.factory()
@onready var previous_shown_inventory: Dictionary = {}
@onready var representations: Dictionary = {}

func _ready() -> void:
    InventoryManager.add_to_inventory("Blue Leaf", 25)
    update()

func update() -> void:
    var to_remove: Array = previous_shown_inventory.keys().filter(func(x): return not InventoryManager.inventory.has(x))
    var to_add: Array = InventoryManager.inventory.keys().filter(func(x): return not previous_shown_inventory.has(x))

    for element in to_remove:
        remove_representation(element)
        
    for element in to_add:
        add_representation(element)

    for ingredient_name in representations.keys():
        var element = representations[ingredient_name]
        (element.get_node("IngredientRepresentation/IngredientAmount") as RichTextLabel).text = "[center]%d[/center]" % [InventoryManager.inventory[ingredient_name]]

    previous_shown_inventory = InventoryManager.inventory

func add_representation(ingredient_name: String) -> void:
    var data: IngredientData = ingredient_data_table.data[ingredient_name]
    var ingredient_representation: Control = inventory_item_scene.instantiate()
    (ingredient_representation.get_node("IngredientRepresentation/IngredientSymbol") as TextureRect).texture = data.sprite
    (ingredient_representation.get_node("IngredientRepresentation/VBoxContainer/IngredientName") as RichTextLabel).text = ingredient_name
    (ingredient_representation.get_node("IngredientRepresentation/IngredientAmount") as RichTextLabel).text = "[center]%d[/center]" % [InventoryManager.inventory[ingredient_name]]
    (ingredient_representation.get_node("Button") as Button).button_down.connect(_choose_value.bind(ingredient_name))
    representations[ingredient_name] = ingredient_representation
    $ScrollContainer/VBoxContainer.add_child(ingredient_representation)

func _choose_value(ingredient_name: String) -> void:
    if not Input.is_key_pressed(KEY_CTRL):
        _take_out(ingredient_name, 1)
        return

    var slider: Control = slider_scene.instantiate()
    var value_slider: Slider = slider.get_node("ValueSlider")
    value_slider.min_value = 0
    value_slider.max_value = InventoryManager.inventory[ingredient_name]
    (slider.get_node("MinimumValueText") as RichTextLabel).text = "[center]%d[/center]" % [value_slider.min_value]
    (slider.get_node("MaximumValueText") as RichTextLabel).text = "[center]%d[/center]" % [value_slider.max_value]
    (slider.get_node("Button") as Button).button_down.connect(_take_out_slider.bind(ingredient_name, value_slider))
    get_tree().current_scene.add_child(slider)

func _take_out(ingredient_name: String, amount: int) -> void:
    for i in range(amount):
        get_tree().current_scene.add_child((load("res://scenes/prefabs/ingredients/%s.tscn" % ingredient_name) as PackedScene).instantiate())
    InventoryManager.remove_from_inventory(ingredient_name, amount)
    if amount == InventoryManager.inventory[ingredient_name]:
        remove_representation(ingredient_name)
        previous_shown_inventory.erase(ingredient_name)
    else:
        (representations[ingredient_name].get_node("IngredientRepresentation/IngredientAmount") as RichTextLabel).text = "[center]%d[/center]" % [InventoryManager.inventory[ingredient_name]]
        

func _take_out_slider(ingredient_name: String, slider: HSlider) -> void:
    _take_out(ingredient_name, slider.value as int)
    slider.get_parent_control().queue_free()


func remove_representation(ingredient_name: String) -> void:
    (representations[ingredient_name] as Control).queue_free()
