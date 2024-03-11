class_name SubstanceDataTable

extends Resource

## key(string) : SubstanceData
var data: Dictionary = {}

static var _instances: Dictionary = {}

static func factory(name: String="main") -> SubstanceDataTable:
    return _instances.get(name, SubstanceDataTable.new())

func _init():
    print(data)