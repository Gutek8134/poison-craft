class_name SubstanceDataTable

extends Resource

## key(substance name) : SubstanceData
@export var data: Dictionary = {}
@export var name: String

static var _instances: Dictionary = {}

static func factory(p_name: String="main") -> SubstanceDataTable:
    if p_name not in _instances:
        if FileAccess.file_exists("res://content/data/%s_substance_table.tres" % p_name):
            _instances[p_name] = load("res://content/data/%s_substance_table.tres" % p_name)
        else:
            _instances[p_name] = SubstanceDataTable.new()
    _instances[p_name].name = p_name
    _instances[p_name]._add_temperature_reactions()
    _instances[p_name].data["example substance"] = SubstanceData.new()
    print(_instances[p_name].data)
    return _instances[p_name]

# TODO: substance creator
func _init() -> void:
    print(data)

func save() -> void:
    var error := ResourceSaver.save(self, "res://content/data/%s_substance_table.tres" % name, ResourceSaver.FLAG_BUNDLE_RESOURCES)
    if error:
        printerr("An error occured: ", error)

func _add_temperature_reactions() -> void:
    for substance_name in data:
        var substance: SubstanceData = data[substance_name]
        var temperature_reactions = [
            SubstanceReaction.new(
                "%s melting" % substance_name,
                substance.name,
                10,
                substance.name,
                0,
                {substance.substance_type + SubstanceData.state_of_matter_to_string(SubstanceData.STATE_OF_MATTER.LIQUID): 10},
                ReactionConditions.new(substance.melting_temperature, substance_name.ignition_temperature, []),
                1),
            SubstanceReaction.new(
                "%s solidification" % substance_name,
                substance.name,
                10,
                substance.name,
                0,
                {substance.substance_type + SubstanceData.state_of_matter_to_string(SubstanceData.STATE_OF_MATTER.SOLID): 10},
                ReactionConditions.new(0, substance_name.melting_temperature, []),
                1),
            SubstanceReaction.new(
                "%s vaporisation" % substance_name,
                substance.name,
                10,
                substance.name,
                0,
                {substance.substance_type + SubstanceData.state_of_matter_to_string(SubstanceData.STATE_OF_MATTER.GAS): 10},
                ReactionConditions.new(substance.vaporisation_temperature, substance_name.ignition_temperature, []),
                1),
            SubstanceReaction.new(
                "%s condensation" % substance_name,
                substance.name,
                10,
                substance.name,
                0,
                {substance.substance_type + SubstanceData.state_of_matter_to_string(SubstanceData.STATE_OF_MATTER.LIQUID): 10},
                ReactionConditions.new(substance.melting_temperature, substance_name.vaporisation_temperature, []),
                1),
        ]
        substance.possible_reactions.append_array(temperature_reactions)