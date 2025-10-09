class_name ShopItem

extends Control

@export var base_price: int = 20
@export var special_discount: float = 0.0
@export var ingredient_name: String
## In grams
@export var ingredient_weight: int = 100
@export var amount_left: int = 1
@export var infinite_supply: bool = false

var price: int

signal run_out(ingredient_name)

func _on_buy() -> void:
    if InventoryManager.gold < price:
        return
    
    InventoryManager.gold -= price
    InventoryManager.add_to_inventory(ingredient_name, ingredient_weight)
    
    amount_left -= ingredient_weight

    if infinite_supply:
        return

    amount_left -= 1
    if amount_left <= 0:
        run_out.emit(ingredient_name)
        queue_free()

func _init(_ingredient_name: String = "", _amount_left: int = 1, _infinite_supply: bool = false, _base_price: int = 20, _special_discount: float = 0.0, _ingredient_weight: int = 100):
    base_price = _base_price
    special_discount = _special_discount
    ingredient_name = _ingredient_name
    ingredient_weight = _ingredient_weight
    amount_left = _amount_left
    infinite_supply = _infinite_supply
