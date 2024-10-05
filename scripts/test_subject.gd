extends Node2D

@onready var data_table := SubstanceDataTable.factory()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func consume(ingredient: Ingredient) -> void:
	for substance_name in ingredient.composition.keys():
		var substance: SubstanceData = data_table.data[substance_name]
		var substance_amount: int = ingredient.composition[substance_name] * ingredient.amount
		
		for effect in substance.effects:
			if effect.minimal_dose <= substance_amount:
				apply_effect(effect)
				

func apply_effect(effect: SubstanceEffect) -> void:
	if not effect:
		return

	await get_tree().create_timer(effect.seconds_to_start).timeout

	match effect.effect_type:
		SubstanceEffect.effect_enum.DEATH:
			die()

		SubstanceEffect.effect_enum.BLINDNESS:
			pass

		SubstanceEffect.effect_enum.BLEEDING:
			pass

		SubstanceEffect.effect_enum.MEMORY_LOSS:
			pass


func die() -> void:
	queue_free()