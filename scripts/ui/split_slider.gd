extends Control

@onready var value_slider := $ValueSlider as Slider
@onready var value_text := $ValueText as LineEdit

func _ready():
    value_text.text = str(value_slider.value as int)

func _on_value_text_submitted(new_text: String) -> void:
    var text_value := float(new_text)
    var actual_value := clampf(text_value, value_slider.min_value, value_slider.max_value)
    if text_value != actual_value:
        value_text.text = str(actual_value as int)
    value_slider.value = actual_value


func _on_slider_value_changed(value: float) -> void:
    value_text.text = str(value as int)
