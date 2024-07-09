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
## In Kelvins
@export var temperature_change: int
## Whether the reaction can occur at lower amounts of substances
## Be warned that it can become too expensive very quickly
@export var scaling: bool

func _eq(other: SubstanceReaction) -> bool:
    return self.name == other.name

func _init(p_name: String, p_substance_name: String="", p_substance_amount: int=0, p_reactant_name: String="", p_reactant_amount: int=0, p_outcome_substances: Dictionary={}, p_reaction_conditions: ReactionConditions=ReactionConditions.new(), p_reaction_time: int=5, p_temperature_change: int=0, p_scaling: bool=false):
    name = p_name
    substance_name = p_substance_name
    substance_amount = p_substance_amount
    reactant_name = p_reactant_name
    reactant_amount = p_reactant_amount
    outcome_substances = p_outcome_substances
    reaction_conditions = p_reaction_conditions
    reaction_time = p_reaction_time
    temperature_change = p_temperature_change
    scaling = p_scaling

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
    output += "\n\t%s\n\tReaction time:%d\n}" % [reaction_conditions, reaction_time]
    return output

## Warning: this can become pretty expensive
## Returns a new object
func scaled(scale: int=- 1, scale_reaction_time: bool=false, scale_temperature_change: bool=false) -> SubstanceReaction:
    var new_outcome_substances: Dictionary = {}
    if scale == - 1:
        scale = Math.gcd(substance_amount, reactant_amount)
        for outcome_substance_amount: int in outcome_substances.values():
            scale = Math.gcd(scale, outcome_substance_amount)

        if scale_reaction_time:
            scale = Math.gcd(scale, reaction_time)
        
        if scale_temperature_change:
            scale = Math.gcd(scale, temperature_change)

        for outcome_substance in outcome_substances:
            new_outcome_substances[outcome_substance] = (outcome_substances[outcome_substance] / scale)
        
    else:
        new_outcome_substances = outcome_substances.duplicate()

    return SubstanceReaction.new("%s (scaled by %d)" % [name, scale],
    substance_name,
    (substance_amount / scale),
    reactant_name,
    (reactant_amount / scale),
    new_outcome_substances,
    reaction_conditions.copy(),
    ((reaction_time / scale) if scale_reaction_time else reaction_time),
    ((temperature_change / scale) if scale_temperature_change else temperature_change),
    false)
