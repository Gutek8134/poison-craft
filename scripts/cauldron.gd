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

const substance_representation_scene := (preload ("res://scenes/prefabs/ui/substance_repr.tscn") as PackedScene)

## In Kelvins, don't set manually outside of testing, use set_target_temperature instead
var current_temperature: int:
	set = _set_current_temperature
## In Kelvins
var target_temperature: int:
	set = set_target_temperature

const DEFAULT_TEMPERATURE_CHANGE = 10
@onready var temperature_change_timer := $Timer as Timer
# Related to causing reactions

## key: string (substance name) = int (amount in grams)
@onready var content: Dictionary = {}

## key: string (substance name) = SubstanceRepresentation
@onready var substance_representations: Dictionary = {}
	
@onready var is_mixing := false

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
@onready var content_display := $substance_scroll/substance_grid as GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	current_temperature = room_temperature
	target_temperature = current_temperature
	_test()

func self_destruct() -> void:
	print("Oh shit! Self destruct!")
	queue_free()

## In Kelvins
func _set_current_temperature(new_temperature: int) -> void:
	current_temperature = new_temperature
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

func start_mixing() -> void:
	is_mixing = true

func increase_target_temperature(value: int=DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature += value

func decrease_target_temperature(value: int=DEFAULT_TEMPERATURE_CHANGE) -> void:
	target_temperature -= value

## Amount in grams
func add_substance(substance: Substance):
	if substance.data.name not in content:
		content[substance.data.name] = substance.amount
		var repr := substance_representation_scene.instantiate()
		(repr as SubstanceRepresentation).substance = substance
		content_display.add_child(repr)
		substance_representations[substance.data.name] = repr
	else:
		content[substance.data.name] += substance.amount
		((substance_representations[substance.data.name] as Node).get_script() as SubstanceRepresentation).substance.amount = content[substance.data.name]
	update_substance_display()
	_update_ongoing_reactions()

## Amount in grams
func add_ingredient(ingredient: Ingredient, amount: int):
	for substance_name in ingredient.composition:
		if substance_name not in content:
			content[substance_name] = amount * ingredient.composition[substance_name]
			var repr := substance_representation_scene.instantiate()
			(repr as SubstanceRepresentation).substance = \
				Substance.new(data_table.data[substance_name], content[substance_name])
			content_display.add_child(repr)
			substance_representations[substance_name] = repr
		else:
			content[substance_name] += amount * ingredient.composition[substance_name]
			(substance_representations[substance_name] as SubstanceRepresentation).substance.amount = content[substance_name]
	update_substance_display()
	_update_ongoing_reactions()

func update_substance_display() -> void:
	for representation: SubstanceRepresentation in substance_representations.values():
		representation.update()
	print(content)

## Interval in seconds
func _start_approaching_target_temperature(interval: int=3) -> void:
	# Changes current temperature in static interval
	temperature_change_timer.wait_time = interval
	temperature_change_timer.start()
	while true:
		await temperature_change_timer.timeout
		# print(current_temperature, "->", target_temperature)
		if abs(target_temperature - current_temperature) <= heating_power:
			break
		if current_temperature > target_temperature:
			current_temperature -= heating_power * interval
		else:
			current_temperature += heating_power * interval
		_update_ongoing_reactions()
		
	current_temperature = target_temperature
	temperature_change_timer.stop()
	_update_ongoing_reactions()

func _update_ongoing_reactions() -> void:
	var real_reactions: Array[SubstanceReaction] = []
	for substance_name in content:
		var substance := data_table.data[substance_name] as SubstanceData
		for possible_reaction in substance.possible_reactions:
			# Reactant not present
			if possible_reaction.reactant_name not in content:
				continue
			# Not enough substance or reactant
			if content[possible_reaction.substance_name] < possible_reaction.substance_amount or content[possible_reaction.reactant_name] < possible_reaction.reactant_amount:
				continue

			var conditions = possible_reaction.reaction_conditions
			# Temperature is too low or too high
			if conditions.min_temperature > current_temperature or conditions.max_temperature < current_temperature:
				continue
			# You need to mix the content in ordet for reaction to occur
			if conditions.mixing and not is_mixing:
				continue
			
			# Some catalyst not present
			var all_catalysts_present: bool = true
			for catalyst in conditions.catalysts:
				if catalyst not in content:
					all_catalysts_present = false
					break
			if not all_catalysts_present:
				continue
			
			# Reaction should occur
			real_reactions.append(possible_reaction)
	
	# Difference update
	# 1 - delete not present in real_reactions
	for reaction_id in range(len(ongoing_reactions)):
		var reaction = ongoing_reactions[reaction_id]
		if reaction not in real_reactions:
			ongoing_reactions.remove_at(reaction_id)
			ongoing_reactions_timers.erase(reaction.name)
	
	# 2 - add not present in ongoing_reactions
	for reaction in real_reactions:
		if reaction not in ongoing_reactions:
			ongoing_reactions.append(reaction)
			var timer = Timer.new()
			timer.one_shot = false
			timer.autostart = false
			timer.wait_time = reaction.reaction_time
			add_child(timer)
			timer.start()
			ongoing_reactions_timers[reaction.name] = timer
			
			_reaction_coroutine(reaction)

func _reaction_coroutine(reaction: SubstanceReaction):
	while true:
		await (ongoing_reactions_timers[reaction.name] as Timer).timeout
		if reaction.name not in ongoing_reactions_timers:
			break
		content[reaction.substance_name] -= reaction.substance_amount
		content[reaction.reactant_name] -= reaction.reactant_amount

		if content[reaction.substance_name] == 0:
			content.erase(reaction.substance_name)
		
		if content[reaction.reactant_name] == 0:
			content.erase(reaction.reactant_name)

		for substance_name: String in reaction.outcome_substances:
			content[substance_name] = content.get(substance_name, 0) + reaction.outcome_substances[substance_name]
		_update_ongoing_reactions()

func _update_temperature_display() -> void:
	temperature_display.text = "[center][font_size=50]%dK[/font_size][/center]" % current_temperature \
if target_temperature == current_temperature \
else "[center][font_size=40]%dK[/font_size]
[font_size=30](%dK)[/font_size][/center]" % [target_temperature, current_temperature]

func _on_decrease_temperature_button_pressed():
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_CTRL):
			decrease_target_temperature(DEFAULT_TEMPERATURE_CHANGE * 5)
		else:
			decrease_target_temperature(DEFAULT_TEMPERATURE_CHANGE * 10)
	elif Input.is_key_pressed(KEY_CTRL):
		decrease_target_temperature(int(float(DEFAULT_TEMPERATURE_CHANGE) / 2))
	else:
		decrease_target_temperature(DEFAULT_TEMPERATURE_CHANGE)

func _on_increase_temperature_button_pressed():
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
	add_substance(Substance.new(data_table.data["Jelenial (liquid)"], 19))
	_update_ongoing_reactions()
	# var printer = func(): print("%s %s" % [ongoing_reactions, content])
	# CoroutinesLib.invoke_repeating(printer, get_tree(), self, 2, 0, 5)
