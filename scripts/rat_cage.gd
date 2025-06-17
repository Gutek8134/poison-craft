extends Node2D

@onready var data_table := SubstanceDataTable.factory()
@onready var rat_buy := $RatBuy as Button
@onready var rat := $Rat as Sprite2D
var feeder_free: bool = true

func _apply_effect(effect: SubstanceEffect, source: String) -> void:
	await get_tree().create_timer(effect.seconds_to_start).timeout
	KnowledgeManager.learn_effect_source(effect, source)
	match effect.effect_type:
		SubstanceEffect.effect_enum.BLEEDING:
			print("I AM BLEEDING")
		SubstanceEffect.effect_enum.DEATH:
			rat.flip_h = false
		SubstanceEffect.effect_enum.MEMORY_LOSS:
			print("WHO AM I?!")
		SubstanceEffect.effect_enum.BLINDNESS:
			rat.flip_v = true
	rat_buy.visible = true

func _on_feeder_body_entered(body: Node2D) -> void:
	if feeder_free and body is Ingredient:
		feeder_free = false

		for substance_name: String in body.container.content.keys():
			var substance: SubstanceData = data_table.data[substance_name]
			for effect in substance.effects.filter(func(effect: SubstanceEffect): return effect.minimal_dose <= body.container.content[substance_name]):
				_apply_effect(effect, substance_name)


		body.queue_free()


func _on_rat_buy_pressed() -> void:
	if InventoryManager.gold >= 10:
		InventoryManager.remove_gold(10)
		feeder_free = true
		rat.flip_h = true
		rat.flip_v = false