class_name SubstanceDataTable

extends Resource

## key(substance name) : SubstanceData
@export var data: Dictionary = {}
@export var name: String

static var _instances: Dictionary = {}

static func factory(p_name: String = "main") -> SubstanceDataTable:
    # print("res://content/data/%s_substance_table.tres" % p_name)
    if p_name not in _instances:
        if FileAccess.file_exists("res://content/data/%s_substance_table.tres" % p_name):
            _instances[p_name] = load("res://content/data/%s_substance_table.tres" % p_name)
            print("%s data table loaded" % [p_name])
        else:
            _instances[p_name] = SubstanceDataTable.new()
            printerr("%s data table does not exist, returning empty" % [p_name])

    _instances[p_name]._add_temperature_reactions()
    # print(_instances[p_name].data)
    return _instances[p_name]

func save() -> void:
    var error := ResourceSaver.save(self, "res://content/data/%s_substance_table.tres" % name, ResourceSaver.FLAG_BUNDLE_RESOURCES)
    if error:
        printerr("An error occured: ", error)

func _add_temperature_reactions() -> void:
    for substance_name in data:
        var substance: SubstanceData = data[substance_name]
        var temperature_reactions: Array[SubstanceReaction]
        if substance.current_state_of_matter == SubstanceData.STATE_OF_MATTER.GAS:
            temperature_reactions = [
                SubstanceReaction.new(
                    "%s condensation" % substance_name,
                    substance.name,
                    10,
                    substance.name,
                    0,
                    {"%s (%s)" % [substance.substance_type, SubstanceData.state_of_matter_to_string(SubstanceData.STATE_OF_MATTER.LIQUID)]: 10},
                    ReactionConditions.new(substance.melting_temperature, substance.vaporisation_temperature - 1, []),
                    1,
                    0,
                    true),
        ]
        if substance.current_state_of_matter == SubstanceData.STATE_OF_MATTER.LIQUID:
            temperature_reactions = [
                SubstanceReaction.new(
                    "%s solidification" % substance_name,
                    substance.name,
                    10,
                    substance.name,
                    0,
                    {"%s (%s)" % [substance.substance_type, SubstanceData.state_of_matter_to_string(SubstanceData.STATE_OF_MATTER.SOLID)]: 10},
                    ReactionConditions.new(0, substance.melting_temperature - 1, []),
                    1,
                    0,
                    true),
                SubstanceReaction.new(
                    "%s vaporisation" % substance_name,
                    substance.name,
                    10,
                    substance.name,
                    0,
                    {"%s (%s)" % [substance.substance_type, SubstanceData.state_of_matter_to_string(SubstanceData.STATE_OF_MATTER.GAS)]: 10},
                    ReactionConditions.new(substance.vaporisation_temperature, substance.ignition_temperature - 1, []),
                    1,
                    0,
                    true),
            ]
        if substance.current_state_of_matter == SubstanceData.STATE_OF_MATTER.SOLID:
            temperature_reactions = [
                SubstanceReaction.new(
                "%s melting" % substance_name,
                substance.name,
                10,
                substance.name,
                0,
                {"%s (%s)" % [substance.substance_type, SubstanceData.state_of_matter_to_string(SubstanceData.STATE_OF_MATTER.LIQUID)]: 10},
                ReactionConditions.new(substance.melting_temperature, substance.ignition_temperature - 1, []),
                1,
                0,
                true),
            ]
        data[substance_name].possible_reactions.append_array(temperature_reactions)