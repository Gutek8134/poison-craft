class_name Ingredient

extends Sprite2D

## key: string (substance name) = int (percentage)
@export var composition: Dictionary = {}

func normalize_composition() -> void:
    var total: int = 0
    for value in composition.values():
        total += value
    
    if total == 100:
        return
    
    # More or less correct
    var factor: float = 100.0 / total
    for key in composition:
        composition[key] = int(composition[key] * factor)
