extends Control

@onready var value_slider := $ValueSlider as Slider
@onready var value_text := $ValueText as LineEdit

func _ready():
	value_text.text = str(value_slider.value as int)

func _on_value_text_submitted(new_text: String) -> void:
	value_slider.value = float(new_text)


func _on_slider_value_changed(value: float) -> void:
	value_text.text = str(value as int)
