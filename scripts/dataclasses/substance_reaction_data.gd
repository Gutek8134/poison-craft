class_name SubstanceReaction
extends Resource

## This reaction unique name
@export var name: String
@export var substance_name: SubstanceName
@export var substance_amount: int
@export var reacts_with: SubstanceName
@export var reactant_amount: int
## key(substance name): int
@export var outcome_substance: Dictionary
@export var reaction_conditions: ReactionConditions
## In seconds
@export var reaction_time: int

func _eq(other: SubstanceReaction) -> bool:
    return self.name == other.name

func _init(p_name: String, p_substance_name: SubstanceName=SubstanceName.new(), p_substance_amount: int=0, p_reacts_with: SubstanceName=SubstanceName.new(), p_reactant_amount: int=0, p_outcome_substance: Dictionary={}, p_reaction_conditions: ReactionConditions=ReactionConditions.new(), p_reaction_time: int=5):
    name = p_name
    substance_name = p_substance_name
    substance_amount = p_substance_amount
    reacts_with = p_reacts_with
    reactant_amount = p_reactant_amount
    outcome_substance = p_outcome_substance
    reaction_conditions = p_reaction_conditions
    reaction_time = p_reaction_time