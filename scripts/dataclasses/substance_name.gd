class_name SubstanceName

extends Resource

@export var name: String
@export var current_state_of_matter: SubstanceData.STATE_OF_MATTER

func _init(p_name: String="", state_of_matter: SubstanceData.STATE_OF_MATTER=SubstanceData.STATE_OF_MATTER.SOLID):
    name = p_name
    current_state_of_matter = state_of_matter

func _eq(other: SubstanceName) -> bool:
    return name == other.name and current_state_of_matter == other.current_state_of_matter
