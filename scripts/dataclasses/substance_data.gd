extends Resource

const SubstanceEffect = preload("res://scripts/dataclasses/substance_effect_data.gd")
const SubstanceReaction = preload("res://scripts/dataclasses/substance_reaction_data.gd")

@export_group("Base Data")
@export var name := SubstanceName.new()
@export var effects: Array[SubstanceEffect] = []
@export var possible_reactions: Array[SubstanceReaction] = []
## In Kelvins
@export var melting_temperature: int = 270
@export var ignition_temperature: int = 500
@export var vaporisation_temperature: int = 400


# Tree structure:
# SubstanceData {
# 	name
# 	effects [
# 		SubstanceEffect {
# 		minimal_dose
#		effect_type
# 		seconds_to_start
# 		effect_strength
# 		}
# 	]
# 	possible_reactions [
# 		SubstanceReaction {
# 		reacts_with
# 		reaction_conditions
# 			ReactionConditions {
# 			min_temperature
# 			max_temperature
# 			catalysts [
# 				SubstanceName
# 			]
# 			mixing
# 		}
# 		reaction_time
# 		}
# 	]
# }
