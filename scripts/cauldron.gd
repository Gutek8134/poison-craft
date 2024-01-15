extends AnimatedSprite2D

const room_temperature: int = 295

@export_group("limits")
@export var max_temperature: int = 570
@export var min_temperature: int = 220
@export_group("attributes")
## Kelvins per second
@export var heating_power: float = 2

# Realted to causing reactions

## key: string (substance name) = int (amount in grams)
var content: Dictionary

## In Kelvins
var current_temperature: float:
	set = set_current_temperature

@onready var is_heating := false
@onready var is_mixing := false

# TODO
@onready var ongoing_reactions: Array[SubstanceReaction] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	current_temperature = room_temperature

func _process(delta):
	if is_heating:
		current_temperature += heating_power * delta

func self_destruct()->void:
	print("Oh shit! Self destruct!")
	queue_free()

func set_current_temperature(new_temperature: float):
	current_temperature = new_temperature
	if current_temperature > max_temperature or current_temperature < min_temperature:
		self_destruct()

func start_heating():
	is_heating = true

func mix():
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