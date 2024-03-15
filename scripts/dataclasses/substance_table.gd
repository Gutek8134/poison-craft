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

# TODO: substance creator
func _init() -> void:
    for substance_name in data:
        var substance = data[substance_name]
        var temperature_reactions = [
            SubstanceReaction.new(
                "%s melting" % substance_name,
                SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.SOLID),
                10,
                SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.SOLID),
                0,
                {SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.LIQUID): 10},
                ReactionConditions.new(substance.melting_temperature, substance_name.ignition_temperature, []),
                1),
            SubstanceReaction.new(
                "%s solidification" % substance_name,
                SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.LIQUID),
                10,
                SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.LIQUID),
                0,
                {SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.SOLID): 10},
                ReactionConditions.new(0, substance_name.melting_temperature, []),
                1),
            SubstanceReaction.new(
                "%s vaporisation" % substance_name,
                SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.LIQUID),
                10,
                SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.LIQUID),
                0,
                {SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.GAS): 10},
                ReactionConditions.new(substance.vaporisation_temperature, substance_name.ignition_temperature, []),
                1),
            SubstanceReaction.new(
                "%s ignition" % substance_name,
                SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.GAS),
                10,
                SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.GAS),
                0,
                {SubstanceName.new(substance_name, SubstanceData.STATE_OF_MATTER.LIQUID): 10},
                ReactionConditions.new(substance.melting_temperature, substance_name.vaporisation_temperature, []),
                1),
        ]
        substance.possible_reactions.append_array(temperature_reactions)
    print(data)

func save() -> void:
    var error := ResourceSaver.save(self, "res://content/data/%s_substance_table.tres" % name, ResourceSaver.FLAG_BUNDLE_RESOURCES)
    if error:
        printerr("An error occured: ", error)