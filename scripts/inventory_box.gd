extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
    if body is Ingredient:
        var ingredient = body as Ingredient
        if ingredient.name == "Unknown Potion":
            return
        InventoryManager.add_to_inventory(ingredient.ingredient_name, ingredient.amount / ingredient.mass_unit)
        body.queue_free()
