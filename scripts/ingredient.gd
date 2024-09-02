class_name Ingredient

extends Node2D

## key: string (substance name) = int (percentage)
@export var composition: Dictionary = {}
@export var amount: int = 100

static var time_to_show_container: float = 0.6
static var time_to_hide_container: float = 0.2

@onready var container := $Container as SubstanceContainer
var __mouse_hovering_over := false
var __mouse_hovering_over_container := false
var __dragging := false
var __container_show_timer: SceneTreeTimer
var __container_hide_timer: SceneTreeTimer

func _ready():
	normalize_composition()
	var data_table = SubstanceDataTable.factory()
	for substance_name: String in composition:
		container.add_substance(data_table.data[substance_name], amount * composition[substance_name] / 100)

func normalize_composition() -> void:
	var total: int = 0
	for value in composition.values():
		total += value
	
	if total == 100:
		return
	
	# More or less correct
	var factor: float = 100.0 / total
	for key in composition:
		composition[key] = int(composition[key] * factor)

func _on_mouse_entered() -> void:
	__mouse_hovering_over = true

	if container.visible:
		if __container_hide_timer:
			__container_hide_timer.time_left = 0
		return

	__container_show_timer = get_tree().create_timer(time_to_show_container)
	await __container_show_timer.timeout
	if __mouse_hovering_over and not __dragging:
		container.visible = true

func _on_mouse_exited() -> void:
	__mouse_hovering_over = false
	__dragging = false

	if not container.visible:
		if __container_show_timer:
			__container_show_timer.time_left = 0
		return

	if __mouse_hovering_over_container:
		return

	__container_hide_timer = get_tree().create_timer(time_to_show_container)
	await __container_hide_timer.timeout
	if not __mouse_hovering_over and not __mouse_hovering_over_container:
		container.visible = false

func _on_container_mouse_entered() -> void:
	if not container.visible:
		return
	
	__mouse_hovering_over_container = true

	if __container_hide_timer:
		__container_hide_timer.time_left = 0

func _on_container_mouse_exited() -> void:
	if not container.visible:
		return
	
	__mouse_hovering_over_container = false

	__container_hide_timer = get_tree().create_timer(time_to_show_container)
	await __container_hide_timer.timeout
	if not __mouse_hovering_over and not __mouse_hovering_over_container:
		container.visible = false

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			__dragging = event.pressed
			if event.pressed:
				container.visible = false
			else:
				__container_show_timer = get_tree().create_timer(time_to_show_container)
				await __container_show_timer.timeout
				if __mouse_hovering_over and not __dragging:
					container.visible = true
	
	if __dragging and event is InputEventMouseMotion:
		position += event.get_screen_relative()
