extends Node2D

@export_group("limits")
@export var max_temperature: int = 700
@export var min_temperature: int = 200
## Grams
@export var max_capacity: int = 50
@export_group("attributes")
## Kelvins per second
@export var heating_power: int = 15
@export var pipe_width: int = 10
@export_group("gameplay")
@export var temperature_change_interval: int = 3
@export var gas_movement_interval: int = 1

## In Kelvins
var current_temperature: int:
	set = _set_current_temperature
## In Kelvins
var target_temperature: int:
	set = set_target_temperature

var is_heating: bool:
	get:
		return target_temperature - current_temperature < 0

var is_cooling: bool:
	get:
		return target_temperature - current_temperature > 0

const DEFAULT_TEMPERATURE_CHANGE = 10
@onready var temperature_change_timer := $temperature_timer as Timer
@onready var gases_movement_timer := $gases_movement_timer as Timer

@onready var content_left := $container_left as SubstanceContainer

@onready var content_right := $container_right as SubstanceContainer

## Queue of gases that will pass through the pipe to the right container
@onready var gases_queue: Array[String] = []

@onready var data_table = SubstanceDataTable.factory()

# Graphics related

@onready var temperature_display := $distillery_sprite/temperature_display as RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_temperature = SubstanceContainer.room_temperature
	target_temperature = current_temperature
	content_left.current_temperature = current_temperature
	content_left.data_table = data_table
	content_right.current_temperature = current_temperature
	content_right.data_table = data_table
	_test()

func self_destruct() -> void:
	print("Oh shit! Self destruct!")
	queue_free()

## In Kelvins
func _set_current_temperature(new_temperature: int) -> void:
	current_temperature = new_temperature
	content_left.current_temperature = current_temperature
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
		
	current_temperature = target_temperature
	temperature_change_timer.stop()

func _start_moving_gases(interval: int=1) -> void:
	gases_movement_timer.wait_time = interval
	gases_movement_timer.start()
	while true:
		await gases_movement_timer.timeout
		
		if gases_queue.is_empty():
			break
		
		var width_left := pipe_width
		while content_left.content[gases_queue[0]] <= width_left:
			width_left -= content_left.content[gases_queue[0]]
			content_right.add_substance(data_table.data[gases_queue[0]], content_left.content[gases_queue[0]])
			content_left.add_substance(data_table.data[gases_queue[0]], -content_left.content[gases_queue[0]])
			gases_queue.remove_at(0)
			
			# Maybe all of the gases have been transported
			if gases_queue.is_empty():
				break
		
		if gases_queue.is_empty():
			break

		content_right.add_substance(data_table.data[gases_queue[0]], width_left)
		content_left.add_substance(data_table.data[gases_queue[0]], -width_left)
		
		_update_ongoing_reactions()
		_update_substance_display()

	gases_movement_timer.stop()
	_update_ongoing_reactions()
	_update_substance_display()

func _update_temperature_display() -> void:
	temperature_display.text = "[center][font_size=50]%dK[/font_size][/center]" % current_temperature \
if target_temperature == current_temperature \
else "[center][font_size=40]%dK[/font_size]
[font_size=30](%dK)[/font_size][/center]" % [target_temperature, current_temperature]

func increase_target_temperature(value: int=DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature += value

func decrease_target_temperature(value: int=DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature -= value

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

## Amount in grams
func add_substance_left(substance: SubstanceData, amount: int) -> void:
	content_left.add_substance(substance, amount)
	content_left.update_substance_display()
	content_left.update_ongoing_reactions()

## Amount in grams
func add_substance_right(substance: SubstanceData, amount: int) -> void:
	content_right.add_substance(substance, amount)
	content_right.update_substance_display()
	content_right.update_ongoing_reactions()

func _update_substance_display() -> void:
	content_left.update_substance_display()
	content_right.update_substance_display()

func _update_ongoing_reactions() -> void:
	for substance_name: String in content_left.content:
		var substance: SubstanceData = data_table.data[substance_name]
		if substance.current_state_of_matter == SubstanceData.STATE_OF_MATTER.GAS and gases_queue.count(substance.name) == 0:
			gases_queue.push_back(substance.name)
	
	if gases_movement_timer.is_stopped():
		_start_moving_gases(gas_movement_interval)
	
	content_left.update_ongoing_reactions()
	content_right.update_ongoing_reactions()

func _test() -> void:
	add_substance_left(data_table.data["Jelenial (liquid)"], 19)
