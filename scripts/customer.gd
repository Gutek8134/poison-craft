class_name Customer

extends Node2D

@export var sprite_size := Vector2(150, 400)
var expected_effects: Array
var escape_needed: bool
## In seconds
var escape_time: int = 0
var tolerance: float = 1.0
var offered_purchase_price: int
var customer_type: String
var customer_name: String

@onready var dialogue_box_1: Node2D = $DialogueBox1
@onready var dialogue_box_2: Node2D = $DialogueBox2
var __original_position: Vector2

func _ready() -> void:
	__original_position = dialogue_box_1.position

static func generate_random_customer() -> Customer:
	const customer_scene: PackedScene = preload("res://scenes/prefabs/customer.tscn")
	const customer_names = ["Bob"]

	# TODO: add more
	var customer_ranges = \
	{
		"Aristocrat": CustomerRange.new(0.15, Pair.new(40, 800), Pair.new(0.05, 0.2), Pair.new(500, 2000),
		{
			[SubstanceEffect.effect_enum.BLINDNESS, 3]: 0.7,
			[SubstanceEffect.effect_enum.DEATH, 2]: 0.3
		},
		Pair.new(1, 1))
	}
	var customer_sprites = \
	{
		"Aristocrat": preload("res://content/images/plus-t.png")
	}

	var new_customer: Customer = customer_scene.instantiate() as Customer
	new_customer.customer_type = customer_ranges.keys().pick_random()
	var customer_range: CustomerRange = customer_ranges[new_customer.customer_type]

	var sprite = new_customer.get_node("Area2D/CollisionShape2D/Sprite2D") as Sprite2D
	sprite.texture = customer_sprites[new_customer.customer_type]
	sprite.scale = new_customer.sprite_size / sprite.texture.get_size()
	new_customer.customer_name = customer_names.pick_random()

	new_customer.escape_needed = randf() < customer_range.escape_needed
	if new_customer.escape_needed:
		new_customer.escape_time = randi_range(customer_range.escape_time.first, customer_range.escape_time.second)
		
	new_customer.tolerance = randf_range(customer_range.tolerance.first, customer_range.tolerance.second)
	new_customer.offered_purchase_price = randi_range(customer_range.offered_purchase_price.first, customer_range.offered_purchase_price.second)

	var number_of_expected_effects = randi_range(customer_range.number_of_effects.first, customer_range.number_of_effects.second)
	if number_of_expected_effects >= len(customer_range.expected_effects.keys()):
		new_customer.expected_effects = customer_range.expected_effects.keys()
	else:
		new_customer.expected_effects = []
		var effects_weight: int = 0
		for weight in customer_range.expected_effects.values():
			effects_weight += weight
		
		# Choose appropriate number of effects to expect, based on CustomerRange expected_effects distribution
		for i in range(number_of_expected_effects):
			var rnd: int = randi_range(0, effects_weight)
			var total: int = 0
			for effect in customer_range.expected_effects:
				total += customer_range.expected_effects[effect]
				if total >= rnd:
					new_customer.expected_effects.append(effect)
					effects_weight -= customer_range.expected_effects[effect]
					customer_range.expected_effects.erase(effect)
					break
		
	return new_customer

func _enter_tree() -> void:
	var spawn: Node2D
	if get_tree().current_scene is not MainScene:
		spawn = get_tree().current_scene.get_node("CustomerSpawn")
	else:
		spawn = (get_tree().current_scene as MainScene).counter_scene.get_node("CustomerSpawn")
	if spawn:
		global_position = spawn.global_position
	else:
		global_position = get_viewport_rect().get_center()

var previous_timer_1: Timer
var previous_timer_2: Timer
## Force box - which dialogue box (1/2) to use; 0 to use default
func say(_text: String, time: int = -1, force_box: int = 0) -> void:
	if (not dialogue_box_1.visible or force_box == 1) and force_box != 2:
		dialogue_box_1.say(_text, time)
		return
	
	dialogue_box_2.say(_text, time)
	

func try_buy_potion(potion: Ingredient) -> void:
	var price = get_final_price(potion)
	if price == 0:
		say("This is worthless!", 5, 2)
		return
	
	say("Thank you", 3, 2)
	InventoryManager.add_gold(price)

func get_final_price(potion: Ingredient) -> int:
	var potion_effects: Array[SubstanceEffect] = []
	for substance_name in potion.content.keys():
		var substance_data: SubstanceData = potion.data_table.data[substance_name]
		var amount: int = potion.content[substance_name]
		potion_effects.append_array(substance_data.effects.filter(func(x: SubstanceEffect): return x.minimal_dose <= amount and x not in potion_effects))

	var potion_effects_names: Array[Array] = potion_effects.map(func(x: SubstanceEffect): return [x.effect_type, x.effect_strength])

	var missing_effects: int = len(expected_effects.filter(func(x): return x not in potion_effects_names))
	var side_effects: int = len(potion_effects_names.filter(func(x): return x not in expected_effects))

	var time_to_poison: int = min(potion_effects.map(func(x: SubstanceEffect): return x.seconds_to_start))

	var mistakes: int = (missing_effects + side_effects + int(max((escape_time - time_to_poison), 0.0) / 30))

	if mistakes == 0:
		return offered_purchase_price

	if mistakes <= roundi(tolerance * 10):
		# See https://www.desmos.com/calculator/a9orntjsht
		# x - mistakes, a - tolerance
		return int(offered_purchase_price / ((1 - tolerance ** 2) * mistakes + 1))
		
	return 0
		
func _to_string() -> String:
	return "%s (%s): I need something with effects: %s. %s. My tolerance is %.2f, and I will pay %s!" % [
				customer_name,
				customer_type,
				", ".join(expected_effects),
				"I need %s seconds to get away with it" % [escape_time] if escape_needed else "I don't need to escape",
				tolerance,
				offered_purchase_price
			]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ingredient:
		if not body.is_potion:
			say("Why are you giving this to me?", 3)
			return
		
		try_buy_potion(body)
		return

var _introduction_is_said: bool = false
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not _introduction_is_said and event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			_introduction_is_said = true
			say("Hello, I'm %s the %s.\nI need a potion with following effects: %s." %
			[customer_name, customer_type, ", ".join(expected_effects.map(func(x): return "%s %s" % [["Death", "Blindness", "Bleeding", "Memory Loss"][x[0]], ["0", "I", "II", "III", "IV", "V"][x[1]]]))],
			15, 0)
			CoroutinesLib.invoke(func(): _introduction_is_said = false, get_tree(), 3)
		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			say("Hello", 3, 0)


class CustomerRange:
	## distribution - dictionary of chances; string->int; can sum up to anything, not needed to normalize
	var expected_effects: Dictionary
	## min-max; int
	var number_of_effects: Pair
	## chance; float
	var escape_needed: float
	## min-max; int in seconds
	var escape_time: Pair
	## min-max; float must be between 0 and 1
	var tolerance: Pair
	## min-max; int
	var offered_purchase_price: Pair
		
	func _init(_escape_needed: float, _escape_time: Pair, _tolerance: Pair, _offered_purchase_price: Pair, _expected_effects: Dictionary, _number_of_effects: Pair) -> void:
		escape_needed = _escape_needed
		escape_time = _escape_time
		tolerance = _tolerance
		offered_purchase_price = _offered_purchase_price
		expected_effects = _expected_effects
		number_of_effects = _number_of_effects
