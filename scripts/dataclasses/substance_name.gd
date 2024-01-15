class_name SubstanceName

extends Resource

@export var name: String

func _init(p_name: String = ""):
    name = p_name

func _eq(other: SubstanceName)->bool:
    return name == other.name
