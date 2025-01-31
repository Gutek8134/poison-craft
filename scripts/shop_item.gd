extends Control

@export var price: int = 20
@export var ingredient_name: String
## In grams
@export var ingredient_weight: int = 100
@export var amount_left: int = 1
@export var infinite_supply: bool = false

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
        queue_free()
