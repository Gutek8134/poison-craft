class_name SalesPerson

extends Node2D

@export var sprite_size := Vector2(150, 400)

@onready var shop_ui = $Shop
@onready var shop_items_container = $Shop/ScrollContainer/GridContainer

const shop_item_scene = preload("res://scenes/prefabs/ui/shop_item.tscn")

## String -> ShopItem
var assortment: Dictionary = {}
var pricing_multiplier: float = 1.0
## String -> Texture
static var salesperson_sprites: Dictionary = {
	"General": preload("res://content/images/minus-t.png")
}


var ingredient_data_table: IngredientDataTable = IngredientDataTable.factory()

const salesperson_scene: PackedScene = preload("res://scenes/prefabs/salesperson.tscn")

static func generate_random_salesperson() -> SalesPerson:
	var new_salesperson: SalesPerson = salesperson_scene.instantiate() as SalesPerson
	print(new_salesperson.pricing_multiplier)
	new_salesperson.pricing_multiplier = randf_range(0.8, 1.2)

	var sprite = new_salesperson.get_node("Area2D/CollisionShape2D/Sprite2D") as Sprite2D
	sprite.texture = salesperson_sprites["General"]
	sprite.scale = new_salesperson.sprite_size / sprite.texture.get_size()

	
	return new_salesperson

func _ready() -> void:
	# print((new_salesperson.ingredient_data_table.data["Blue Leaf"] as IngredientData).composition)
	assortment = {
		"Blue Leaf": shop_item_scene.instantiate()
	}
	assortment["Blue Leaf"].ingredient_name = "Blue Leaf"
	print(assortment)
	setup_shop()
	update_shop_display()

func setup_shop() -> void:
	for item in assortment.values():
		assert(item is ShopItem)
		item.price = roundi(item.base_price * (pricing_multiplier - item.special_discount))
		item.run_out.connect(_on_item_run_out)
		shop_items_container.add_child(item)

func update_shop_display() -> void:
	pass

func _on_area_2d_body_entered(_body: Node2D) -> void:
	pass

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			shop_ui.visible = !shop_ui.visible

func _on_item_run_out(ingredient_name: String) -> void:
	assortment.erase(ingredient_name)

func _enter_tree() -> void:
	var spawn: Node2D
	if get_tree().current_scene is not MainScene:
		spawn = get_tree().current_scene.get_node("SalesSpawn")
	else:
		spawn = (get_tree().current_scene as MainScene).counter_scene.get_node("SalesSpawn")
	if spawn:
		global_position = spawn.global_position
	else:
		global_position = get_viewport_rect().get_center()

func _init(_pricing_multiplier: float = 1.0) -> void:
	pricing_multiplier = _pricing_multiplier
