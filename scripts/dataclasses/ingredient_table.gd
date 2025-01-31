class_name IngredientDataTable

extends Resource

## key(ingredient name) : Ingredient composition (dictionary)
@export var data: Dictionary = {}
@export var name: String

static var _instances: Dictionary = {}

static func factory(p_name: String = "main") -> IngredientDataTable:
    # print("res://content/data/%s_ingredient_table.tres" % p_name)
    if p_name not in _instances:
        if FileAccess.file_exists("res://content/data/%s_ingredient_table.tres" % p_name):
            _instances[p_name] = load("res://content/data/%s_ingredient_table.tres" % p_name)
            print("%s data table loaded" % [p_name])
        else:
            _instances[p_name] = IngredientDataTable.new()
            printerr("%s data table does not exist, returning empty" % [p_name])

    _instances[p_name].name = p_name
    # print(_instances[p_name].data)
    return _instances[p_name]

func save() -> void:
    var error := ResourceSaver.save(self, "res://content/data/%s_ingredient_table.tres" % name, ResourceSaver.FLAG_BUNDLE_RESOURCES)
    if error:
        printerr("An error occured: ", error)