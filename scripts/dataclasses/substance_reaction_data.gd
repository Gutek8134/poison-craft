class_name SubstanceReaction
extends Resource

## This substance name
@export var name: SubstanceName
@export var reacts_with: SubstanceName
@export var reaction_conditions: ReactionConditions
## In seconds
@export var reaction_time: int

func _init(p_name: SubstanceName = SubstanceName.new(), p_reacts_with: SubstanceName = SubstanceName.new(), p_reaction_conditions: ReactionConditions = ReactionConditions.new(), p_reaction_time: int = 5):
    name = p_name
    reacts_with = p_reacts_with
    reaction_conditions = p_reaction_conditions
    reaction_time = p_reaction_time