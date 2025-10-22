extends Node2D

var potion_table := IngredientDataTable.factory("potion")

func add_potion(potion_name: String, data: IngredientData) -> void:
	if potion_name in potion_table:
		print(potion_name, " is already in the table")
		return

	potion_table.data[potion_name] = data

func get_potion(potion_name: String) -> IngredientData:
	return potion_table.data.get(potion_name)
