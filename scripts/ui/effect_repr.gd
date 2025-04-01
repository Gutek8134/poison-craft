class_name EffectRepresentation

extends BoxContainer

@export var effect: SubstanceEffect


func _init(p_effect: SubstanceEffect = null):
	if p_effect != null:
		effect = p_effect

func _ready():
	update()

func update() -> void:
	if not effect or not is_instance_valid(effect):
		return
		
	($EffectName as RichTextLabel).text = "[center]%s[/center]" % [["Death", "Blindness", "Bleeding", "Memory Loss"][effect.effect_type]]
	($Strength as RichTextLabel).text = "[center]%s[/center]" % [["I", "II", "III", "IV", "V"][effect.effect_strength]]
	($MinimalDose as RichTextLabel).text = "[center]%d[/center] g" % [effect.minimal_dose]
	($TimeToStart as RichTextLabel).text = "[center]%d[/center] s" % [effect.seconds_to_start]
