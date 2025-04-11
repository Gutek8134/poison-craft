class_name Ingredient

extends RigidBody2D

## key: string (substance name) = int (percentage)
## Normalized to sum up to 100
@export var ingredient_name: String
@export var composition: Dictionary = {}
## Must be a multiple of mass unit, mass in grams
@export var amount: int = 100
@export var _gravity_scale: float = 1.3
@export var _force_scale: float = 0.5
@export var _velocity_damp_scale: float = 0.8
@export var _maximum_force: int = 300
@export var _minimum_force: int = -300
# @export var _throw_velocity_scale: float = 2.5

static var time_to_show_container: float = 0.6
static var time_to_hide_container: float = 0.2

@onready var container := $Container as SubstanceContainer
@onready var data_table := SubstanceDataTable.factory()
@onready var is_potion: bool = false
## In grams
var mass_unit: int
var __mouse_hovering_over := false
var __mouse_hovering_over_container := false
var __dragging := false
var __container_show_timer: SceneTreeTimer
var __container_hide_timer: SceneTreeTimer
var __container_position_offset: Vector2
var __minimum_force_vector: Vector2
var __maximum_force_vector: Vector2

var split_slider_scene := preload("res://scenes/prefabs/ui/split_slider.tscn")

func _ready():
	for value in composition.values():
		mass_unit += value
	__container_position_offset = container.global_position - global_position
	mass = amount / 1000.
	gravity_scale = _gravity_scale
	mass_unit = 0
	for substance_mass in composition.values():
		mass_unit += substance_mass
	__minimum_force_vector = Vector2(_minimum_force, _minimum_force)
	__maximum_force_vector = Vector2(_maximum_force, _maximum_force)
	for substance_name: String in composition:
		@warning_ignore("integer_division")
		container.add_substance(data_table.data[substance_name], amount / mass_unit * composition[substance_name])

func _physics_process(_delta):
	if __dragging:
		var dragging_vector = (get_global_mouse_position() - global_position)
		dragging_vector.x = dragging_vector.x * abs(dragging_vector.x)
		dragging_vector.y = dragging_vector.y * abs(dragging_vector.y)
		apply_force((dragging_vector * mass * _force_scale - linear_velocity * _velocity_damp_scale * sqrt(mass)).clamp(__minimum_force_vector, __maximum_force_vector))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and __dragging:
		if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			__dragging = false
			gravity_scale = _gravity_scale
			# linear_velocity *= _throw_velocity_scale
			if __mouse_hovering_over:
				_on_mouse_entered()

func _on_mouse_entered() -> void:
	__mouse_hovering_over = true

	if container.visible:
		if __container_hide_timer:
			__container_hide_timer.time_left = 0
		return

	__container_show_timer = get_tree().create_timer(time_to_show_container)
	await __container_show_timer.timeout
	if __mouse_hovering_over and not __dragging and linear_velocity.is_zero_approx():
		container.visible = true
		container.global_rotation = 0
		container.global_position = global_position + __container_position_offset

func _on_mouse_exited() -> void:
	__mouse_hovering_over = false

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

var double_clicked := false
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.double_click:
				double_clicked = true
				print("double click!")
				var split_slider := split_slider_scene.instantiate()
				(split_slider.get_node("MinimumValueText") as RichTextLabel).text = "[center]0[/center]"
				(split_slider.get_node("MaximumValueText") as RichTextLabel).text = "[center]%d[/center]"%amount
				var split_value_slider := (split_slider.get_node("ValueSlider") as Slider)
				split_value_slider.min_value = 0
				split_value_slider.max_value = amount
				get_tree().root.add_child(split_slider)
				await (split_slider.get_node("Button") as Button).pressed
				var duplicate_ingredient := self.duplicate() as Ingredient
				duplicate_ingredient.composition = self.composition
				duplicate_ingredient.amount = split_value_slider.value as int
				duplicate_ingredient.mass = split_value_slider.value / 1000
				duplicate_ingredient.position = self.position + Vector2(0, -50)
				duplicate_ingredient.z_index = self.z_index
				self.amount -= split_value_slider.value as int
				self.mass = self.amount / 1000.
				for substance_name: String in composition:
					container.add_substance(data_table.data[substance_name], -split_value_slider.value * composition[substance_name] / 100)
				get_tree().current_scene.add_child(duplicate_ingredient)
				split_slider.queue_free()
				return
			__dragging = event.pressed
			gravity_scale = !event.pressed
			if event.pressed:
				double_clicked = false
				await get_tree().create_timer(time_to_hide_container).timeout
				if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not double_clicked:
					container.visible = false
			else:
				__container_show_timer = get_tree().create_timer(time_to_show_container)
				await __container_show_timer.timeout
				if __mouse_hovering_over and not __dragging:
					container.visible = true
					container.global_rotation = 0
					container.global_position = global_position + __container_position_offset
