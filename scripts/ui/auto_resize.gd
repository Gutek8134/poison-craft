class_name ResizingRTL

extends RichTextLabel

@export var max_width: float = 500

signal resize_finished

var __resize_label: RichTextLabel

func _ready() -> void:
	__resize_label = get_tree().current_scene.get_node("ResizeLabel") as RichTextLabel

func change_text(new_text: String) -> void:
	# block the signals so "finished" does not trigger this function again
	set_block_signals(true)
	__resize_label.text = new_text
	var original_autowrap = __resize_label.autowrap_mode
	# save the position
	var tmp = __resize_label.global_position
	# move it out of the way to avoid flashing
	__resize_label.global_position.x = -100000
	# disable autowrap
	__resize_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	# make it 0, 0
	__resize_label.size = Vector2.ZERO
	# wait one frame
	await get_tree().process_frame
	# now we have the size with no autowrap
	# if the width is bigger than max width clamp it
	var w = clampf(__resize_label.size.x, 1, max_width)
	var h = __resize_label.size.y
	# restore the autowrap mode
	__resize_label.autowrap_mode = original_autowrap
	# set the maximum size we got
	__resize_label.size.x = w
	# wait one frame for the text to resize
	await get_tree().process_frame
	# if the height is bigger than before we have multiple lines
	# and we may need to make the width smaller
	if __resize_label.size.y > h:
		# save the height
		h = __resize_label.size.y
		# keep lowering the width until the height changes
		while true:
			# lower the width a bit
			__resize_label.size.x -= 10
			# wait one frame
			await get_tree().process_frame
			# check if the height changed
			if not is_equal_approx(__resize_label.size.y, h):
				# if it changed we made the textbox too small
				# restore the width and break the while loop
				__resize_label.size.x += 10
				break
	# wait one frame
	await get_tree().process_frame
	# restore the height
	__resize_label.size.y = h
	# restore the original position
	__resize_label.global_position = tmp

	size = __resize_label.size
	text = new_text

	# unblock the signals
	set_block_signals(false)

	resize_finished.emit()
