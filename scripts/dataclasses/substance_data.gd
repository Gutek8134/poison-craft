class_name SubstanceData

extends Resource

@export_group("Base Data")
@export var substance_type := ""
@export var current_state_of_matter := SubstanceData.STATE_OF_MATTER.SOLID
@export var effects: Array[SubstanceEffect] = []
@export var possible_reactions: Array[SubstanceReaction] = []
## In Kelvins
@export var melting_temperature: int = 270
## In Kelvins
@export var ignition_temperature: int = 500
## In Kelvins
@export var vaporisation_temperature: int = 400

@export_group("Graphics")
@export var icon: Texture2D

var name: String:
    get:
        return "%s (%s)" % [substance_type, SubstanceData.state_of_matter_to_string(current_state_of_matter)]

var full_string_representation: bool = true

enum STATE_OF_MATTER {
    GAS,
    LIQUID,
    SOLID
}

# Tree structure:
# SubstanceData {
#   substance_type: string,
#   current_state_of_matter: SOM
#   name: type (state_of_matter)
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
    icon = Texture2D.new()

func _eq(other: SubstanceData) -> bool:
    return name == other.name

func _to_string(max_effects: int=10, max_reactions: int=5) -> String:
    if full_string_representation:
        return self.full_to_string()
    var output: String = self.name
    output += "; " + (str(len(self.possible_reactions)) if len(self.effects) > max_effects else ", ".join(self.effects))
    output += "; " + (str(len(self.possible_reactions)) if len(self.possible_reactions) > max_reactions else ", ".join(self.possible_reactions))
    return output

func full_to_string() -> String:
    var output := "%s {\n\teffects:\n" % [name]
    for effect in effects:
        output += "\t\t%s\n" % effect
    output += "\tpossible reactions:\n"
    for reaction in possible_reactions:
        output += "%s\n" % ("\t\t" + reaction.full_to_string().replace("\n", "\n\t\t"))
    output += "}\n"
    return output

static func state_of_matter_to_string(state_of_matter: STATE_OF_MATTER) -> String:
    return SubstanceData.STATE_OF_MATTER.keys()[state_of_matter].to_lower()