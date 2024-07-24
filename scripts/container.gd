class_name SubstanceContainer

extends Node2D

static var room_temperature: int = 295

const substance_representation_scene := (preload ("res://scenes/prefabs/ui/substance_repr.tscn") as PackedScene)

var current_temperature: int:
	set = _set_current_temperature

@onready var is_mixing: bool = false
@onready var is_closed: bool = false

## key: string (substance name) = int (amount in grams)
@onready var content: Dictionary = {}

## key: string (substance name) = SubstanceRepresentation
@onready var substance_representations: Dictionary = {}

var data_table

@onready var ongoing_reactions: Array[SubstanceReaction] = []
## key(string - reaction name): Timer
@onready var ongoing_reactions_timers: Dictionary = {}

@onready var timers_parent_node: Node = self
@onready var content_display := $substance_scroll/substance_grid as GridContainer

func update_substance_display() -> void:
	for representation: SubstanceRepresentation in substance_representations.values():
		representation.update()
	print(content)

func update_ongoing_reactions() -> void:
	var real_reactions: Array[SubstanceReaction] = []
	for substance_name in content:
		var substance := data_table.data[substance_name] as SubstanceData
		for possible_reaction in substance.possible_reactions:
			# Reactant not present
			if possible_reaction.reactant_name not in content:
				continue
			# Not enough substance or reactant
			if content[possible_reaction.substance_name] < possible_reaction.substance_amount or content[possible_reaction.reactant_name] < possible_reaction.reactant_amount:
				# still may scale down
				if not possible_reaction.scaling:
					continue

				possible_reaction = possible_reaction.scaled()
				# check if there is enough substances if it can
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
	var ongoing_reactions_copy := ongoing_reactions.duplicate()
	var offset: int = 0

	for reaction_id in range(len(ongoing_reactions)):
		var reaction = ongoing_reactions[reaction_id]
		if reaction not in real_reactions:
			ongoing_reactions_copy.remove_at(reaction_id - offset)
			offset += 1
			ongoing_reactions_timers[reaction.name].queue_free()
			ongoing_reactions_timers.erase(reaction.name)
			
	ongoing_reactions = ongoing_reactions_copy
	
	# 2 - add not present in ongoing_reactions
	for reaction in real_reactions:
		if reaction not in ongoing_reactions:
			ongoing_reactions.append(reaction)
			var timer = Timer.new()
			timer.one_shot = false
			timer.autostart = false
			timer.wait_time = reaction.reaction_time
			timers_parent_node.add_child(timer)
			timer.start()
			ongoing_reactions_timers[reaction.name] = timer
			
			_reaction_coroutine(reaction)

func _reaction_coroutine(reaction: SubstanceReaction) -> void:
	var reaction_timer := (ongoing_reactions_timers[reaction.name] as Timer)
	while true:
		await reaction_timer.timeout
		if reaction.name not in ongoing_reactions_timers:
			break
		
		_add_substance(data_table.data[reaction.substance_name], -reaction.substance_amount)
		_add_substance(data_table.data[reaction.reactant_name], -reaction.reactant_amount)

		for substance_name: String in reaction.outcome_substances:
			_add_substance(data_table.data[substance_name], reaction.outcome_substances[substance_name])
		
		current_temperature += reaction.temperature_change

		update_ongoing_reactions()
		update_substance_display()

func add_substance(substance: SubstanceData, amount: int) -> void:
	_add_substance(substance, amount)
	update_ongoing_reactions()
	update_substance_display()

## Amount in grams
func _add_substance(substance: SubstanceData, amount: int) -> void:
	if amount == 0:
		return

	content[substance.name] = content.get(substance.name, 0) + amount

	assert(content[substance.name] >= 0, "Content's value became negative, WTF?!")
	
	if amount > 0:
		if substance.name not in substance_representations:
			var repr := substance_representation_scene.instantiate() as SubstanceRepresentation
			repr.substance = Substance.new(substance, amount)
			content_display.add_child(repr)
			substance_representations[substance.name] = repr
			return

	elif content[substance.name] == 0:
		(substance_representations[substance.name] as SubstanceRepresentation).queue_free()
		substance_representations.erase(substance.name)
		return

	(substance_representations[substance.name] as SubstanceRepresentation).substance.amount = content[substance.name]

func start_mixing() -> void:
	is_mixing = true

func stop_mixing() -> void:
	is_mixing = false

func close() -> void:
	is_closed = true

func open() -> void:
	is_closed = false

func _set_current_temperature(new_temperature: int) -> void:
	current_temperature = new_temperature
	update_ongoing_reactions()
	update_substance_display()
