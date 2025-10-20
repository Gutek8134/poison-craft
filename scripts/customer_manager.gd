extends Node

signal customer_went_away()

func _ready() -> void:
    spawn_customer.call_deferred()
    spawn_salesperson.call_deferred()
    customer_went_away.connect(func(): return )

func spawn_customer():
    var customer: Customer = Customer.generate_random_customer()
    if get_tree().current_scene is MainScene:
        (get_tree().current_scene as MainScene).counter_scene.add_child.call_deferred(customer)

func spawn_salesperson() -> void:
    var salesperson: SalesPerson = SalesPerson.generate_random_salesperson()
    if get_tree().current_scene is MainScene:
        (get_tree().current_scene as MainScene).counter_scene.add_child.call_deferred(salesperson)
