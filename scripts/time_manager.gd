extends Node

func _ready() -> void:
    spawn_customer.call_deferred()

func spawn_customer():
    var customer: Customer = Customer.generate_random_customer()
    if get_tree().current_scene is not MainScene:
        get_tree().current_scene.add_child.call_deferred(customer)
    else:
        (get_tree().current_scene as MainScene).counter_scene.add_child.call_deferred(customer)
