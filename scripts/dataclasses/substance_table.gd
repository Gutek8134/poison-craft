class_name SubstanceDataTable

extends Resource

## key(string) : SubstanceData
var data: Dictionary = {}
var name: String

static var _instances: Dictionary = {}

static func factory(p_name: String="main") -> SubstanceDataTable:
    if p_name not in _instances:
        _instances[p_name] = load("res://content/data/%s_substance_table.tres" % p_name)
    _instances[p_name].name = p_name
    return _instances[p_name]

# TODO: resource creator
# TODO: automatic melting, vaporisation, and inverses as SubstanceReaction
func _init() -> void:
    print(data)

func save() -> void:
    var error := ResourceSaver.save(self, "res://content/data/%s_substance_table.tres" % name, ResourceSaver.FLAG_BUNDLE_RESOURCES)
    if error:
        printerr("An error occured: ", error)