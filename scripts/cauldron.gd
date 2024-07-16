extends Node2D

@export_group("limits")
@export var max_temperature: int = 570
@export var min_temperature: int = 280
@export_group("attributes")
## Kelvins per second
@export var heating_power: int = 2
@export_group("gameplay")
@export var temperature_change_interval: int = 3

const substance_container_scene := (preload ("res://scenes/prefabs/container.tscn") as PackedScene)

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
		return target_temperature - current_temperature < 0

var is_cooling: bool:
	get:
		return target_temperature - current_temperature > 0

@onready var data_table = SubstanceDataTable.factory()

@onready var ongoing_reactions: Array[SubstanceReaction] = []
## key(string - reaction name): Timer
@onready var ongoing_reactions_timers: Dictionary = {}

# Graphics related

@onready var temperature_display := $cauldron_sprite/temperature_display as RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	content = $Container
	content.data_table = data_table
	content.timers_parent_node = self
	current_temperature = SubstanceContainer.room_temperature
	target_temperature = current_temperature
	_test()

func self_destruct() -> void:
	print("Oh shit! Self destruct!")
	queue_free()

## In Kelvins
func _set_current_temperature(new_temperature: int) -> void:
	current_temperature = new_temperature
	content.current_temperature = new_temperature
	_update_temperature_display()
	if current_temperature > max_temperature or current_temperature < min_temperature:
		self_destruct()

func set_target_temperature(new_temperature: int) -> void:
	if target_temperature == current_temperature:
		target_temperature = clamp(new_temperature, min_temperature, max_temperature)
		_start_approaching_target_temperature(temperature_change_interval)
	else:
		target_temperature = clamp(new_temperature, min_temperature, max_temperature)
	_update_temperature_display()

func increase_target_temperature(value: int=DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature += value

func decrease_target_temperature(value: int=DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature -= value

## Amount in grams
func add_substance(substance: SubstanceData, amount: int) -> void:
	content.add_substance(substance, amount)
	content.update_substance_display()
	content.update_ongoing_reactions()

## Amount in grams
func add_ingredient(ingredient: Ingredient, amount: int) -> void:
	for substance_name in ingredient.composition:
		var substance_amount = amount * ingredient.composition[substance_name]
		content.add_substance(data_table.data[substance_name], substance_amount)
		
	content.update_substance_display()
	content.update_ongoing_reactions()

## Interval in seconds
func _start_approaching_target_temperature(interval: int=3) -> void:
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
		content.update_ongoing_reactions()
		
	current_temperature = target_temperature
	temperature_change_timer.stop()
	content.update_ongoing_reactions()

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
		decrease_target_temperature(int(float(DEFAULT_TEMPERATURE_CHANGE) / 2))
	else:
		decrease_target_temperature(DEFAULT_TEMPERATURE_CHANGE)

func _on_increase_temperature_button_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_CTRL):
			increase_target_temperature(DEFAULT_TEMPERATURE_CHANGE * 5)
		else:
			increase_target_temperature(DEFAULT_TEMPERATURE_CHANGE * 10)
	elif Input.is_key_pressed(KEY_CTRL):
		increase_target_temperature(int(float(DEFAULT_TEMPERATURE_CHANGE) / 2))
	else:
		increase_target_temperature(DEFAULT_TEMPERATURE_CHANGE)

func _test() -> void:
	add_substance(data_table.data["Jelenial (liquid)"], 19)
	# var printer = func(): print("%s %s" % [ongoing_reactions, content])
	# CoroutinesLib.invoke_repeating(printer, get_tree(), self, 1, 0, 5)
