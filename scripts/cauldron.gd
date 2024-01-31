extends Node2D

const room_temperature: int = 295

@export_group("limits")
@export var max_temperature: int = 570
@export var min_temperature: int = 280
@export_group("attributes")
## Kelvins per second
@export var heating_power: int = 2
@export_group("gameplay")
@export var temperature_change_interval: int = 3


## In Kelvins, don't set manually outside of testing, use set_target_temperature instead
var current_temperature: int:
	set = _set_current_temperature
## In Kelvins
var target_temperature: int:
	set = set_target_temperature


@onready var temperature_change_timer := $Timer as Timer
# Related to causing reactions

## key: string (substance name) = int (amount in grams)
var content: Dictionary
	
@onready var is_mixing := false

var is_heating: bool:
	get:
		return target_temperature - current_temperature < 0

var is_cooling: bool:
	get:
		return target_temperature - current_temperature < 0
	

# TODO
@onready var ongoing_reactions: Array[SubstanceReaction] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	current_temperature = room_temperature
	target_temperature = current_temperature


func self_destruct()->void:
	print("Oh shit! Self destruct!")
	queue_free()

## In Kelvins
func _set_current_temperature(new_temperature: int)->void:
	current_temperature = new_temperature
	if current_temperature > max_temperature or current_temperature < min_temperature:
		self_destruct()

func set_target_temperature(new_temperature: int)->void:
	if target_temperature == current_temperature:
		target_temperature = clamp(new_temperature, min_temperature, max_temperature)
		_start_approaching_target_temperature(temperature_change_interval)
	else:
		target_temperature = clamp(new_temperature, min_temperature, max_temperature)

func start_mixing()->void:
	is_mixing = true

## Amount in grams
func add_substance(substance: Substance, amount: int):
	if substance.data.name.name not in content:
		content[substance.data.name.name] = amount
	else:
		content[substance.data.name.name] += amount

## Amount in grams
func add_ingredient(ingredient: Ingredient, amount: int):
	for substance_name in ingredient.composition:
		content[substance_name] += amount * ingredient.composition[substance_name]

## Interval in seconds
func _start_approaching_target_temperature(interval: int = 3)->void:
	# Changes current temperature in static interval
	temperature_change_timer.wait_time = interval
	temperature_change_timer.start()
	while abs(target_temperature - current_temperature) > heating_power:
		if current_temperature > target_temperature:
			current_temperature -= heating_power*interval
		else:
			current_temperature += heating_power*interval
		await temperature_change_timer.timeout
		
	current_temperature = target_temperature
	temperature_change_timer.stop()
