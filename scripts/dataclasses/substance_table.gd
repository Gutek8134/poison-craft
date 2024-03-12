class_name SubstanceDataTable

extends Resource

## key(string) : SubstanceData
var data: Dictionary = {}

static var _instances: Dictionary = {}

static func factory(name: String="main") -> SubstanceDataTable:
    return _instances.get(name, SubstanceDataTable.new())

# TODO: getting data table from .csv
# TODO: automatic melting, vaporisation, and inverses as SubstanceReaction
func _init():
    print(data)