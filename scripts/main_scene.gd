class_name MainScene

extends Node2D

@export var move_time: float = 1.5
@export var move_x: float = 1200
@export var move_y: float = 800

@onready var scene_holder = $Scenes
@onready var cauldron_scene: Node2D = $Scenes/CauldronScene
@onready var counter_scene: Node2D = $Scenes/Counter
@onready var distillery_scene: Node2D = $Scenes/DistilleryScene
@onready var cage_scene: Node2D = $Scenes/RatCage

@onready var scenes = {Vector2i(0, 1): cauldron_scene, Vector2i(1, 1): counter_scene, Vector2i(2, 1): distillery_scene, Vector2i(1, 0): cage_scene}

@onready var currently_selected_scene: Node2D = cauldron_scene
@onready var currently_selected_scene_index: Vector2i = Vector2i(0, 1)

@onready var inventory_ui: inventory_ui_class = $InventoryUI

const inventory_ui_class = preload("res://scripts/ui/inventory_ui.gd")

var scene_movement_timer: SceneTreeTimer
var starting_position: Vector2
var ending_position: Vector2

func _ready() -> void:
	inventory_ui.update_spawn_node()
	InventoryManager.gold_display = $CurrentGold

func _process(_delta: float) -> void:
	if scene_movement_timer and is_instance_valid(scene_movement_timer) and not is_zero_approx(scene_movement_timer.time_left):
		scene_holder.position = starting_position.lerp(ending_position, (move_time - scene_movement_timer.time_left) / move_time)

func _unhandled_key_input(event: InputEvent) -> void:
	if scene_movement_timer and is_instance_valid(scene_movement_timer) and not is_zero_approx(scene_movement_timer.time_left):
		return
	var next_scene: Node2D
	var next_scene_index: Vector2i
	if event.is_action_released("Left"):
		next_scene_index = currently_selected_scene_index + Vector2i(-1, 0)
		next_scene = scenes.get(next_scene_index)
		if next_scene == null:
			return
		starting_position = scene_holder.position
		ending_position = scene_holder.position + Vector2.RIGHT * move_x
		scene_movement_timer = get_tree().create_timer(move_time)
		currently_selected_scene = next_scene
		currently_selected_scene_index = next_scene_index
		inventory_ui.update_spawn_node()
	elif event.is_action_released("Right"):
		next_scene_index = currently_selected_scene_index + Vector2i(1, 0)
		next_scene = scenes.get(next_scene_index)
		if next_scene == null:
			return
		starting_position = scene_holder.position
		ending_position = scene_holder.position + Vector2.LEFT * move_x
		scene_movement_timer = get_tree().create_timer(move_time)
		currently_selected_scene = next_scene
		currently_selected_scene_index = next_scene_index
		inventory_ui.update_spawn_node()
	elif event.is_action_released("Up"):
		next_scene_index = currently_selected_scene_index + Vector2i(0, -1)
		next_scene = scenes.get(next_scene_index)
		if next_scene == null:
			return
		starting_position = scene_holder.position
		ending_position = scene_holder.position + Vector2.DOWN * move_y
		scene_movement_timer = get_tree().create_timer(move_time)
		currently_selected_scene = next_scene
		currently_selected_scene_index = next_scene_index
		inventory_ui.update_spawn_node()
	elif event.is_action_released("Down"):
		next_scene_index = currently_selected_scene_index + Vector2i(0, 1)
		next_scene = scenes.get(next_scene_index)
		if next_scene == null:
			return
		starting_position = scene_holder.position
		ending_position = scene_holder.position + Vector2.UP * move_y
		scene_movement_timer = get_tree().create_timer(move_time)
		currently_selected_scene = next_scene
		currently_selected_scene_index = next_scene_index
		inventory_ui.update_spawn_node()
