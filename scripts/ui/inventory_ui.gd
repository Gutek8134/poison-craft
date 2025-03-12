extends Control

@export var x_offset: float = 460
@export var time_to_show_inventory: float = 0.75

const inventory_item_scene: PackedScene = preload("res://scenes/prefabs/ui/inventory_item.tscn") as PackedScene
const slider_scene: PackedScene = preload("res://scenes/prefabs/ui/split_slider.tscn") as PackedScene
var ingredient_data_table = IngredientDataTable.factory()

var __inventory_show_timer: SceneTreeTimer
var __inventory_hide_timer: SceneTreeTimer

@onready var representations: Dictionary = {}
@onready var ingredient_spawn_position: Vector2
@onready var original_x = position.x

# Primitive lock, should suffice
@onready var updating: bool = false
signal __update_ready()

func _ready() -> void:
    visible = false
    position.x -= x_offset
    InventoryManager.inventory_ui = self
    update()
    var spawn_node: Node2D
    if get_tree().current_scene is not MainScene:
        spawn_node = get_tree().current_scene.get_node("IngredientSpawn")
        ingredient_spawn_position = spawn_node.global_position
    else:
        ingredient_spawn_position = Vector2.ZERO

func _process(_delta):
    if Input.is_action_just_pressed("inventory"):
        toggle_visibility()

    if __inventory_hide_timer and __inventory_hide_timer.time_left > 0:
        position.x = original_x - lerpf(x_offset, 0, __inventory_hide_timer.time_left / time_to_show_inventory)
    
    if __inventory_show_timer and __inventory_show_timer.time_left > 0:
        position.x = original_x - lerpf(0, x_offset, __inventory_show_timer.time_left / time_to_show_inventory)
        
    
func toggle_visibility():
        # Needs to hide itself
        if visible:
            # It's already hiding, no need to do anything
            if __inventory_hide_timer and __inventory_hide_timer.time_left > 0:
                return

            # Start hiding
            __inventory_hide_timer = get_tree().create_timer(time_to_show_inventory)
            await __inventory_hide_timer.timeout
            position.x = original_x - x_offset
            visible = false

        # Needs to show itself
        else:
            # It's already showing, no need to do anything
            if __inventory_show_timer and __inventory_show_timer.time_left > 0:
                return
            
            # Start showing
            update()
            __inventory_show_timer = get_tree().create_timer(time_to_show_inventory)
            visible = true
            await __inventory_show_timer.timeout
            position.x = original_x


func update() -> void:
    if updating:
        await __update_ready
    
    updating = true
    var to_remove: Array = representations.keys().filter(func(x): return not InventoryManager.inventory.has(x))
    var to_add: Array = InventoryManager.inventory.keys().filter(func(x): return not representations.has(x))

    for element in to_remove:
        remove_representation(element)
        
    for element in to_add:
        add_representation(element)

    for ingredient_name in representations.keys():
        var element = representations[ingredient_name]
        (element.get_node("IngredientRepresentation/IngredientAmount") as RichTextLabel).text = "[center]%d[/center]" % [InventoryManager.inventory[ingredient_name]]

    print("UPDATE", representations, InventoryManager.inventory)
    updating = false
    __update_ready.emit()

func update_spawn_node() -> void:
    var spawn_node: Node2D = (get_tree().current_scene as MainScene).currently_selected_scene.get_node("IngredientSpawn")
    ingredient_spawn_position = spawn_node.global_position

func add_representation(ingredient_name: String) -> void:
    print("adding repr")
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
    slider.position = get_viewport_rect().get_center()
    var value_slider: Slider = slider.get_node("ValueSlider")
    value_slider.min_value = 0
    value_slider.max_value = InventoryManager.inventory[ingredient_name]
    (slider.get_node("ValueSlider/MinimumValueText") as RichTextLabel).text = "[center]%d[/center]" % [value_slider.min_value]
    (slider.get_node("ValueSlider/MaximumValueText") as RichTextLabel).text = "[center]%d[/center]" % [value_slider.max_value]
    (slider.get_node("Button") as Button).button_down.connect(_take_out_slider.bind(ingredient_name, value_slider))
    get_tree().current_scene.add_child(slider)

func _take_out(ingredient_name: String, amount: int) -> void:
    var ingredient_instance := (load("res://scenes/prefabs/ingredients/%s.tscn" % ingredient_name) as PackedScene).instantiate() as Ingredient
    ingredient_instance.amount = amount
    ingredient_instance.global_position = ingredient_spawn_position
    get_tree().current_scene.add_child(ingredient_instance)
    if amount == InventoryManager.inventory[ingredient_name]:
        remove_representation(ingredient_name)
    else:
        (representations[ingredient_name].get_node("IngredientRepresentation/IngredientAmount") as RichTextLabel).text = "[center]%d[/center]" % [InventoryManager.inventory[ingredient_name]]
    InventoryManager.remove_from_inventory(ingredient_name, amount)
        

func _take_out_slider(ingredient_name: String, slider: HSlider) -> void:
    _take_out(ingredient_name, slider.value as int)
    slider.get_parent_control().queue_free()


func remove_representation(ingredient_name: String) -> void:
    (representations[ingredient_name] as Control).queue_free()
    representations.erase(ingredient_name)
