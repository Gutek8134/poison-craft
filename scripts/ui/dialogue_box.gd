class_name DialogueBox

extends Node2D

@export var margins: Vector2 = Vector2(50, 50)

var timer: Timer
var text_label: ResizingRTL
var bubble: Sprite2D
var __original_position: Vector2

func _ready() -> void:
	text_label = $RichTextLabel
	__original_position = position
	bubble = $Bubble

func say(_text: String, time: int = -1) -> void:
	if timer and is_instance_valid(timer):
		timer.timeout.emit()
	text_label.change_text("[font_size=45]%s[/font_size]" % _text)
	await text_label.resize_finished
	visible = true
	#TODO: keep right side constant
	
	bubble.scale = (text_label.size * text_label.scale + margins * 2) / bubble.texture.get_size()
	bubble.position = text_label.size / 2 + text_label.position

	position = __original_position - text_label.size / 2
	
	if time > 0:
		timer = Timer.new()
		get_tree().root.add_child(timer)
		timer.wait_time = time
		timer.one_shot = true
		timer.start()
		await timer.timeout
		timer.queue_free()
		visible = false
	return
