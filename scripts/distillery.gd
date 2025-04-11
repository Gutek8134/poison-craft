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
var current_temperature_left: int:
	set = _set_current_temperature_left
## In Kelvins
var target_temperature_left: int:
	set = set_target_temperature_left
## In Kelvins
var current_temperature_right: int:
	set = _set_current_temperature_right
## In Kelvins
var target_temperature_right: int:
	set = set_target_temperature_right

var is_heating: bool:
	get:
		return target_temperature_left - current_temperature_left > 0

var is_cooling: bool:
	get:
		return target_temperature_left - current_temperature_left < 0

const DEFAULT_TEMPERATURE_CHANGE = 10
@onready var temperature_change_timer_left := $temperature_timer_left as Timer
@onready var temperature_change_timer_right := $temperature_timer_right as Timer
@onready var gases_movement_timer := $gases_movement_timer as Timer

@onready var content_left := $container_left as SubstanceContainer

@onready var content_right := $container_right as SubstanceContainer

## Queue of gases that will pass through the pipe to the right container
@onready var gases_queue: Array[String] = []

@onready var data_table = SubstanceDataTable.factory()

# Graphics related

@onready var temperature_display_left := $distillery_sprite/temperature_display_left as RichTextLabel
@onready var temperature_display_right := $distillery_sprite/temperature_display_right as RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_temperature_left = SubstanceContainer.room_temperature
	target_temperature_left = SubstanceContainer.room_temperature
	current_temperature_right = SubstanceContainer.room_temperature
	target_temperature_right = SubstanceContainer.room_temperature
	content_left.current_temperature = current_temperature_left
	content_right.current_temperature = current_temperature_right
	_test()

func self_destruct() -> void:
	print("Oh shit! Self destruct!")
	queue_free()

## In Kelvins
func _set_current_temperature_left(new_temperature: int) -> void:
	current_temperature_left = new_temperature
	content_left.current_temperature = current_temperature_left
	if current_temperature_left > max_temperature or current_temperature_left < min_temperature:
		self_destruct()
	_update_temperature_display()
	_update_ongoing_reactions()

## In Kelvins
func _set_current_temperature_right(new_temperature: int) -> void:
	current_temperature_right = new_temperature
	content_right.current_temperature = current_temperature_right
	if current_temperature_right > max_temperature or current_temperature_right < min_temperature:
		self_destruct()
	_update_temperature_display()
	_update_ongoing_reactions()

func set_target_temperature_left(new_temperature: int) -> void:
	if target_temperature_left == current_temperature_left:
		target_temperature_left = clamp(new_temperature, min_temperature, max_temperature)
		_start_approaching_target_temperature_left(temperature_change_interval)
	else:
		target_temperature_left = clamp(new_temperature, min_temperature, max_temperature)
	_update_temperature_display()

func set_target_temperature_right(new_temperature: int) -> void:
	if target_temperature_right == current_temperature_right:
		target_temperature_right = clamp(new_temperature, min_temperature, max_temperature)
		_start_approaching_target_temperature_right(temperature_change_interval)
	else:
		target_temperature_right = clamp(new_temperature, min_temperature, max_temperature)
	_update_temperature_display()

## Interval in seconds
func _start_approaching_target_temperature_left(interval: int = 3) -> void:
	# Changes current temperature in static interval
	temperature_change_timer_left.wait_time = interval
	temperature_change_timer_left.start()
	while true:
		await temperature_change_timer_left.timeout
		# print(current_temperature_left, "->", target_temperature_left)
		if abs(target_temperature_left - current_temperature_left) <= heating_power * interval:
			break
		if current_temperature_left > target_temperature_left:
			current_temperature_left -= heating_power * interval
		else:
			current_temperature_left += heating_power * interval
		
	current_temperature_left = target_temperature_left
	temperature_change_timer_left.stop()

## Interval in seconds
func _start_approaching_target_temperature_right(interval: int = 3) -> void:
	# Changes current temperature in static interval
	temperature_change_timer_right.wait_time = interval
	temperature_change_timer_right.start()
	while true:
		await temperature_change_timer_right.timeout
		# print(current_temperature_right, "->", target_temperature_right)
		if abs(target_temperature_right - current_temperature_right) <= heating_power * interval:
			break
		if current_temperature_right > target_temperature_right:
			current_temperature_right -= heating_power * interval
		else:
			current_temperature_right += heating_power * interval
		
	current_temperature_right = target_temperature_right
	temperature_change_timer_right.stop()

func _start_moving_gases(interval: int = 1) -> void:
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
	temperature_display_left.text = "[center][font_size=50]%dK[/font_size][/center]" % current_temperature_left \
if target_temperature_left == current_temperature_left \
else "[center][font_size=40]%dK[/font_size]
[font_size=30](%dK)[/font_size][/center]" % [target_temperature_left, current_temperature_left]
	
	temperature_display_right.text = "[center][font_size=50]%dK[/font_size][/center]" % current_temperature_right \
if target_temperature_right == current_temperature_right \
else "[center][font_size=40]%dK[/font_size]
[font_size=30](%dK)[/font_size][/center]" % [target_temperature_right, current_temperature_right]

func increase_target_temperature_left(value: int = DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature_left += value

func decrease_target_temperature_left(value: int = DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature_left -= value

func increase_target_temperature_right(value: int = DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature_right += value

func decrease_target_temperature_right(value: int = DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature_right -= value

func _on_decrease_temperature_left_button_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_CTRL):
			decrease_target_temperature_left(DEFAULT_TEMPERATURE_CHANGE * 5)
		else:
			decrease_target_temperature_left(DEFAULT_TEMPERATURE_CHANGE * 10)
	elif Input.is_key_pressed(KEY_CTRL):
		decrease_target_temperature_left(int(float(DEFAULT_TEMPERATURE_CHANGE) / 2))
	else:
		decrease_target_temperature_left(DEFAULT_TEMPERATURE_CHANGE)

func _on_increase_temperature_left_button_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_CTRL):
			increase_target_temperature_left(DEFAULT_TEMPERATURE_CHANGE * 5)
		else:
			increase_target_temperature_left(DEFAULT_TEMPERATURE_CHANGE * 10)
	elif Input.is_key_pressed(KEY_CTRL):
		increase_target_temperature_left(int(float(DEFAULT_TEMPERATURE_CHANGE) / 2))
	else:
		increase_target_temperature_left(DEFAULT_TEMPERATURE_CHANGE)

func _on_decrease_temperature_right_button_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_CTRL):
			decrease_target_temperature_right(DEFAULT_TEMPERATURE_CHANGE * 5)
		else:
			decrease_target_temperature_right(DEFAULT_TEMPERATURE_CHANGE * 10)
	elif Input.is_key_pressed(KEY_CTRL):
		decrease_target_temperature_right(int(float(DEFAULT_TEMPERATURE_CHANGE) / 2))
	else:
		decrease_target_temperature_right(DEFAULT_TEMPERATURE_CHANGE)

func _on_increase_temperature_right_button_pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_CTRL):
			increase_target_temperature_right(DEFAULT_TEMPERATURE_CHANGE * 5)
		else:
			increase_target_temperature_right(DEFAULT_TEMPERATURE_CHANGE * 10)
	elif Input.is_key_pressed(KEY_CTRL):
		increase_target_temperature_right(int(float(DEFAULT_TEMPERATURE_CHANGE) / 2))
	else:
		increase_target_temperature_right(DEFAULT_TEMPERATURE_CHANGE)

## Amount in grams
func add_substance_left(substance: SubstanceData, amount: int) -> void:
	if content_left.is_closed:
		print("Can't add a substance while the container is closed bro")
		return
	content_left.add_substance(substance, amount)
	content_left.update_substance_display()
	content_left.update_ongoing_reactions()

## Amount in grams
func add_substance_right(substance: SubstanceData, amount: int) -> void:
	if content_right.is_closed:
		print("Can't add a substance while the container is closed bro")
		return
	content_right.add_substance(substance, amount)
	content_right.update_substance_display()
	content_right.update_ongoing_reactions()

func add_ingredient(ingredient: Ingredient, amount: int) -> void:
	for substance_name in ingredient.composition:
		@warning_ignore("integer_division")
		var substance_amount: int = amount / ingredient.mass_unit * ingredient.composition[substance_name]
		add_substance_left(data_table.data[substance_name], substance_amount)
		
	_update_substance_display()
	_update_ongoing_reactions()

func _update_substance_display() -> void:
	content_left.update_substance_display()
	content_right.update_substance_display()

func _update_ongoing_reactions() -> void:
	for substance_name: String in content_left.content:
		var substance: SubstanceData = data_table.data[substance_name]
		if substance.current_state_of_matter == SubstanceData.STATE_OF_MATTER.GAS and not gases_queue.has(substance.name):
			gases_queue.push_back(substance.name)
	
	if gases_movement_timer.is_stopped() and len(gases_queue) > 0:
		_start_moving_gases(gas_movement_interval)
	
	content_left.update_ongoing_reactions()
	content_right.update_ongoing_reactions()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ingredient:
		add_ingredient(body, body.amount)
		body.queue_free()

func _test() -> void:
	add_substance_left(data_table.data["Jelenial (liquid)"], 19)