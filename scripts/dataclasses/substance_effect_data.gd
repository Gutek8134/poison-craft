extends Resource

## Let's say this is in miligrams, not like any of it actually exists
@export var minimal_dose: int = 1
@export var effect_type := effect_enum.DEATH
@export var seconds_to_start: int = 0
@export var effect_strength: int = 1

enum effect_enum {
    DEATH,
    BLINDNESS,
    BLEEDING,
    MEMORY_LOSS
}