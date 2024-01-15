class_name ReactionConditions

extends Resource

@export var min_temperature: int
@export var max_temperature: int
@export var catalysts: Array[SubstanceName]
@export var mixing: bool

func _init(p_min_temperature: int = 200, p_max_temperature: int = 370, p_catalysts: Array[SubstanceName] = [], p_mixing: bool = false):
    min_temperature = p_min_temperature
    max_temperature = p_max_temperature
    catalysts = p_catalysts
    mixing = p_mixing