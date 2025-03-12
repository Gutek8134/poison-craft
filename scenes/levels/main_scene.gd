class_name MainScene

extends Node2D

@export var move_time: float = 2.5
@export var move_x: float = 1200
@export var move_y: float = 800

@onready var scene_holder = $Scenes
@onready var cauldron_scene: Node2D = $Scenes/CauldronScene
@onready var counter_scene: Node2D = $Scenes/Counter

@onready var currently_selected_scene: Node2D = cauldron_scene

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

    if event.is_action_released("Left") and currently_selected_scene == cauldron_scene:
        starting_position = scene_holder.position
        ending_position = scene_holder.position + Vector2.LEFT * move_x
        scene_movement_timer = get_tree().create_timer(move_time)
        currently_selected_scene = counter_scene
        inventory_ui.update_spawn_node()
    elif event.is_action_released("Right") and currently_selected_scene == counter_scene:
        starting_position = scene_holder.position
        ending_position = scene_holder.position + Vector2.RIGHT * move_x
        scene_movement_timer = get_tree().create_timer(move_time)
        currently_selected_scene = cauldron_scene
        inventory_ui.update_spawn_node()
