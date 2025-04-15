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

func is_equal(other: SubstanceEffect) -> bool:
    return self.minimal_dose == other.minimal_dose \
            and self.effect_type == other.effect_type \
            and self.seconds_to_start == other.seconds_to_start \
            and self.effect_strength == other.effect_strength

func is_in_list(list: Array) -> bool:
    for element in list:
        if is_equal(element):
            return true
    return false

func _to_string() -> String:
    return "Effect %s; minimum %dg, %ds; strength %d" % [["Death", "Blindness", "Bleeding", "Memory Loss"][self.effect_type], minimal_dose, seconds_to_start, effect_strength]
