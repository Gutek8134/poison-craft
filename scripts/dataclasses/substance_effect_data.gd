class_name SubstanceEffect

extends Resource

## Let's say this is in miligrams, not like any of it actually exists
@export var minimal_dose: int
@export var effect_type: effect_enum
@export var seconds_to_start: int
@export var effect_strength: int

enum effect_enum {
    DEATH,
    BLINDNESS,
    BLEEDING,
    MEMORY_LOSS
}

func _init(p_minimal_dose: int = 1, p_effect_type: effect_enum = effect_enum.DEATH, p_seconds_to_start: int = 0, p_effect_strength: int = 1):
    minimal_dose = p_minimal_dose
    effect_type = p_effect_type
    seconds_to_start = p_seconds_to_start
    effect_strength = p_effect_strength
