class_name EffectRepresentation

extends BoxContainer

@export var effect: SubstanceEffect
var source_substance_name: String


func _init(p_effect: SubstanceEffect = null, p_source_substance: String = ""):
	if p_effect != null:
		effect = p_effect
	if p_source_substance != "":
		source_substance_name = p_source_substance

func _ready():
	update()

func update() -> void:
	if not effect or not is_instance_valid(effect):
		return

	print(KnowledgeManager.is_effect_source_known(effect, source_substance_name), KnowledgeManager.known_effect_sources, effect._to_string(), source_substance_name)
	if KnowledgeManager.is_effect_source_known(effect, source_substance_name):
		($EffectName as RichTextLabel).text = "[center]%s[/center]" % [["Death", "Blindness", "Bleeding", "Memory Loss"][effect.effect_type]]
		($Strength as RichTextLabel).text = "[center]%s[/center]" % [["I", "II", "III", "IV", "V"][effect.effect_strength]]
		($MinimalDose as RichTextLabel).text = "[center]%d[/center] g" % [effect.minimal_dose]
		($TimeToStart as RichTextLabel).text = "[center]%d[/center] s" % [effect.seconds_to_start]
		return

	($EffectName as RichTextLabel).text = "[center]Unknown Effect[/center]"
	($Strength as RichTextLabel).text = "[center]%s[/center]" % [["I", "II", "III", "IV", "V"][effect.effect_strength]]
	($MinimalDose as RichTextLabel).text = "[center]%d[/center]g" % [effect.minimal_dose]
	($TimeToStart as RichTextLabel).text = "[center]???[/center]s"
