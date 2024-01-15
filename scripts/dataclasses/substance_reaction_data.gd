extends Resource

## Substance name
@export var reacts_with := SubstanceName.new("")
## Dictionary[condition_type, value]
## example: {iTEMPERATURE: 100, bMIXING: true}
@export var reaction_conditions := ReactionConditions.new()
## In seconds
@export var reaction_time: int = 1