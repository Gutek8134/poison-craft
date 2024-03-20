class_name SubstanceData

extends Resource

@export_group("Base Data")
@export var substance_type := ""
@export var current_state_of_matter := SubstanceData.STATE_OF_MATTER.SOLID
@export var effects: Array[SubstanceEffect] = []
@export var possible_reactions: Array[SubstanceReaction] = []
## In Kelvins
@export var melting_temperature: int = 270
@export var ignition_temperature: int = 500
@export var vaporisation_temperature: int = 400

@export_group("Graphics")
@export var icon: Image

var name: String:
    get:
        return substance_type + SubstanceData.state_of_matter_to_string(current_state_of_matter)

enum STATE_OF_MATTER {
    GAS,
    LIQUID,
    SOLID
}

# Tree structure:
# SubstanceData {
# 	name {
#       name: string,
#       current_state_of_matter: SOM
#   }
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
#       name
#       substance_name
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

func _init(p_name: String="", p_effects: Array[SubstanceEffect]=[], p_possible_reactions: Array[SubstanceReaction]=[], p_melting_temperature: int=270, p_ignition_temperature: int=500, p_vaporisation_temperature: int=400):
    substance_type = p_name
    effects = p_effects
    possible_reactions = p_possible_reactions
    melting_temperature = p_melting_temperature
    ignition_temperature = p_ignition_temperature
    vaporisation_temperature = p_vaporisation_temperature
    icon = Image.new()

func _eq(other: SubstanceData) -> bool:
    return name == other.name

static func state_of_matter_to_string(state_of_matter: STATE_OF_MATTER) -> String:
    return SubstanceData.STATE_OF_MATTER.keys()[state_of_matter]