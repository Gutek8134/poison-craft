class_name SubstanceReaction
extends Resource

## This reaction's unique name
@export var name: String
@export var substance_name: String
@export var substance_amount: int
@export var reactant_name: String
@export var reactant_amount: int
## key(substance name): int
@export var outcome_substances: Dictionary
@export var reaction_conditions: ReactionConditions
## In seconds
@export var reaction_time: int

func _eq(other: SubstanceReaction) -> bool:
    return self.name == other.name

func _init(p_name: String, p_substance_name: String="", p_substance_amount: int=0, p_reactant_name: String="", p_reactant_amount: int=0, p_outcome_substances: Dictionary={}, p_reaction_conditions: ReactionConditions=ReactionConditions.new(), p_reaction_time: int=5):
    name = p_name
    substance_name = p_substance_name
    substance_amount = p_substance_amount
    reactant_name = p_reactant_name
    reactant_amount = p_reactant_amount
    outcome_substances = p_outcome_substances
    reaction_conditions = p_reaction_conditions
    reaction_time = p_reaction_time

func _to_string() -> String:
    return "(Reaction) %s" % [self.name]

func full_to_string() -> String:
    var output := "%s {\n\t%d %s + %d %s ->" % [name, substance_amount, substance_name, reactant_amount, reactant_name]
    var separate := false
    for subst_name in outcome_substances:
        if separate:
            output += ","
        output += " %d %s" % [outcome_substances[subst_name],subst_name]
        separate = true
    output += "\n\t%s\n\t%d\n}" % [reaction_conditions, reaction_time]
    return output