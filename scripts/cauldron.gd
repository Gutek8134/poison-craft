extends Node2D

@export_group("limits")
@export var max_temperature: int = 570
@export var min_temperature: int = 260
@export_group("attributes")
## Kelvins per second
@export var heating_power: int = 2
@export var cauldron_width: int = 50
@export_group("gameplay")
@export var temperature_change_interval: int = 3
@export var gas_movement_interval: int = 1

const substance_container_scene := (preload("res://scenes/prefabs/container.tscn") as PackedScene)
const potion_scene := (preload("res://scenes/prefabs/ingredients/Potion.tscn") as PackedScene)

## In Kelvins, use set_target_temperature for 
var current_temperature: int:
	set = _set_current_temperature
## In Kelvins
var target_temperature: int:
	set = set_target_temperature

const DEFAULT_TEMPERATURE_CHANGE = 10
@onready var temperature_change_timer := $Timer as Timer
# Related to causing reactions

## key: string (substance name) = int (amount in grams)
@onready var content: SubstanceContainer

var is_heating: bool:
	get:
		return target_temperature - current_temperature > 0

var is_cooling: bool:
	get:
		return target_temperature - current_temperature < 0

@onready var data_table = SubstanceDataTable.factory()

@onready var ongoing_reactions: Array[SubstanceReaction] = []
## key(string - reaction name): Timer
@onready var ongoing_reactions_timers: Dictionary = {}
@onready var gases_movement_timer := $gases_movement_timer as Timer

## Queue of gases that will escape the cauldron
@onready var gases_queue: Array[String] = []

# Graphics related

@onready var temperature_display := $cauldron_sprite/temperature_display as RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	content = $Container
	content.timers_parent_node = self
	current_temperature = SubstanceContainer.room_temperature
	target_temperature = current_temperature
	content.inner_temperature_change.connect(_external_temperature_change)
	_test()

func self_destruct() -> void:
	print("Oh shit! Self destruct!")
	queue_free()

func _external_temperature_change() -> void:
	current_temperature = content.current_temperature
	_start_approaching_target_temperature()
	_update_temperature_display()

## In Kelvins
func _set_current_temperature(new_temperature: int) -> void:
	current_temperature = new_temperature
	content.current_temperature = new_temperature
	if current_temperature > max_temperature or current_temperature < min_temperature:
		self_destruct()
	_update_temperature_display()
	_update_ongoing_reactions()

func set_target_temperature(new_temperature: int) -> void:
	if target_temperature == current_temperature:
		target_temperature = clamp(new_temperature, min_temperature, max_temperature)
		_start_approaching_target_temperature(temperature_change_interval)
	else:
		target_temperature = clamp(new_temperature, min_temperature, max_temperature)
	_update_temperature_display()

func increase_target_temperature(value: int = DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature += value

func decrease_target_temperature(value: int = DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature -= value

## Amount in grams
func add_substance(substance: SubstanceData, amount: int) -> void:
	if content.is_closed:
		print("Can't add a substance while the container is closed bro")
		return
	content.add_substance(substance, amount)
	_update_substance_display()
	_update_ongoing_reactions()

## Amount in grams
func add_ingredient(ingredient: Ingredient, amount: int) -> void:
	for substance_name in ingredient.composition:
		@warning_ignore("integer_division")
		var substance_amount: int = amount / ingredient.mass_unit * ingredient.composition[substance_name]
		content.add_substance(data_table.data[substance_name], substance_amount)
		
	_update_substance_display()
	_update_ongoing_reactions()

## Interval in seconds
func _start_approaching_target_temperature(interval: int = 3) -> void:
	# Changes current temperature in static interval
	temperature_change_timer.wait_time = interval
	temperature_change_timer.start()
	while true:
		await temperature_change_timer.timeout
		# print(current_temperature, "->", target_temperature)
		if abs(target_temperature - current_temperature) <= heating_power * interval:
			break
		if current_temperature > target_temperature:
			current_temperature -= heating_power * interval
		else:
			current_temperature += heating_power * interval
		
	current_temperature = target_temperature
	temperature_change_timer.stop()

func _update_temperature_display() -> void:
	temperature_display.text = "[center][font_size=50]%dK[/font_size][/center]" % current_temperature \
if target_temperature == current_temperature \
else "[center][font_size=40]%dK[/font_size]
[font_size=30](%dK)[/font_size][/center]" % [target_temperature, current_temperature]

func _on_decrease_temperature_button_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_CTRL):
			decrease_target_temperature(DEFAULT_TEMPERATURE_CHANGE * 5)
		else:
			decrease_target_temperature(DEFAULT_TEMPERATURE_CHANGE * 10)
	elif Input.is_key_pressed(KEY_CTRL):
		decrease_target_temperature(int(DEFAULT_TEMPERATURE_CHANGE / 2.))
	else:
		decrease_target_temperature(DEFAULT_TEMPERATURE_CHANGE)

func _on_increase_temperature_button_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_CTRL):
			increase_target_temperature(DEFAULT_TEMPERATURE_CHANGE * 5)
		else:
			increase_target_temperature(DEFAULT_TEMPERATURE_CHANGE * 10)
	elif Input.is_key_pressed(KEY_CTRL):
		increase_target_temperature(int(DEFAULT_TEMPERATURE_CHANGE / 2.))
	else:
		increase_target_temperature(DEFAULT_TEMPERATURE_CHANGE)

func _on_lid_toggled(toggled_on: bool) -> void:
	$LidStaticBody.process_mode = Node.PROCESS_MODE_ALWAYS if toggled_on else Node.PROCESS_MODE_DISABLED
	if toggled_on:
		content.close()
	else:
		content.open()

func _on_take_out() -> void:
	if content.content.is_empty():
		return

	var new_potion := (potion_scene.instantiate() as Ingredient)
	new_potion.is_potion = true
	new_potion.composition = content.content.duplicate()
	var sum: int = 0
	for amount in content.content.values():
		sum += amount
	new_potion.amount = sum
	new_potion.mass = sum / 1000.
	new_potion.position = $Button2.position
	new_potion.z_index = -1
	content.clear_content()
	get_tree().current_scene.add_child(new_potion)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ingredient:
		add_ingredient(body, body.amount)
		body.queue_free()

func _start_moving_gases(interval: int = 1) -> void:
	gases_movement_timer.wait_time = interval
	gases_movement_timer.start()
	while true:
		await gases_movement_timer.timeout
		
		if gases_queue.is_empty():
			break
		
		var width_left := cauldron_width
		while content.content[gases_queue[0]] <= width_left:
			width_left -= content.content[gases_queue[0]]
			content.add_substance(data_table.data[gases_queue[0]], -content.content[gases_queue[0]])
			gases_queue.remove_at(0)
			
			# Maybe all of the gases have been transported
			if gases_queue.is_empty():
				break
		
		if gases_queue.is_empty():
			break

		content.add_substance(data_table.data[gases_queue[0]], -width_left)
		
		_update_ongoing_reactions()
		_update_substance_display()

	gases_movement_timer.stop()
	_update_ongoing_reactions()
	_update_substance_display()

func _update_ongoing_reactions() -> void:
	if not content.is_closed:
		for substance_name: String in content.content:
			var substance: SubstanceData = data_table.data[substance_name]
			if substance.current_state_of_matter == SubstanceData.STATE_OF_MATTER.GAS and gases_queue.count(substance.name) == 0:
				gases_queue.push_back(substance.name)
		
		if gases_movement_timer.is_stopped():
			_start_moving_gases(gas_movement_interval)

	content.update_ongoing_reactions()

func _update_substance_display() -> void:
	content.update_substance_display()

func _test() -> void:
	pass
	# var customer = Customer.generate_random_customer()
	# get_tree().current_scene.add_child.call_deferred(customer)
	# print(customer)
	# add_substance(data_table.data["Jelenial (liquid)"], 50)
	# add_substance(data_table.data["Ogr (solid)"], 20)
	# var printer = func(): print("%s %s" % [ongoing_reactions, content])
	# CoroutinesLib.invoke_repeating(printer, get_tree(), self, 1, 0, 5)
