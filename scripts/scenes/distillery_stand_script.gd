extends Scene

const Distillery = preload("res://scripts/distillery.gd")

func _update_scene() -> void:
	($Distillery as Distillery)._update_content_visibility()
