extends Node

## key: SubstanceEffect = Array[string (substance name)]
var known_effect_sources: Dictionary = {}

func learn_effect_source(effect: SubstanceEffect, source: String) -> void:
	print("Learnt effect %s from source %s" % [effect.to_string(), source])
	var known_effect = find_known_effect(effect)
	if known_effect != null:
		known_effect_sources[known_effect].append(source)
		return

	known_effect_sources[effect] = [source]

func is_effect_source_known(effect: SubstanceEffect, source: String) -> bool:
	var known_effect = find_known_effect(effect)
	return known_effect != null and known_effect_sources[known_effect].has(source)

func find_known_effect(effect: SubstanceEffect) -> SubstanceEffect:
	for known_effect in known_effect_sources.keys():
		if effect.is_equal(known_effect):
			return known_effect
			
	return null
