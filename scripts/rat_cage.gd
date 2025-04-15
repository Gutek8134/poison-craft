extends Node2D

@onready var data_table = SubstanceDataTable.factory()
var feeder_free: bool = true

func _apply_effect(effect: SubstanceEffect, source: String) -> void:
	await get_tree().create_timer(effect.seconds_to_start).timeout
	KnowledgeManager.learn_effect_source(effect, source)
	match effect.effect_type:
		SubstanceEffect.effect_enum.BLEEDING:
			print("I AM BLEEDING")
		SubstanceEffect.effect_enum.DEATH:
			($Rat as Sprite2D).flip_h = true
		SubstanceEffect.effect_enum.MEMORY_LOSS:
			print("WHO AM I?!")
		SubstanceEffect.effect_enum.BLINDNESS:
			($Rat as Sprite2D).flip_v = true

func _on_feeder_body_entered(body: Node2D) -> void:
	if feeder_free and body is Ingredient:
		feeder_free = false

		for substance_name: String in body.container.content.keys():
			var substance: SubstanceData = data_table.data[substance_name]
			for effect in substance.effects.filter(func(effect: SubstanceEffect): return effect.minimal_dose <= body.container.content[substance_name]):
				_apply_effect(effect, substance_name)


		body.queue_free()
