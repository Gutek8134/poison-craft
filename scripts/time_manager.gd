extends Node

func _ready() -> void:
    spawn_customer()

func spawn_customer():
    var customer: Customer = Customer.generate_random_customer()
    get_tree().current_scene.add_child.call_deferred(customer)
