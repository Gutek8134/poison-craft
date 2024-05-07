extends Node

@export var substance: Substance

var gas_image := preload ("res://content/images/states of matter/gas.png") as Texture2D
var liquid_image := preload ("res://content/images/states of matter/liquid.png") as Texture2D
var solid_image := preload ("res://content/images/states of matter/solid.png") as Texture2D

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	($SubstanceSymbol as TextureRect).texture = substance.data.icon

	($VBoxContainer/SubstanceName as RichTextLabel).text = "[center]%s[/center]" % [substance.data.substance_type.to_upper()]

	match substance.data.current_state_of_matter:
		SubstanceData.STATE_OF_MATTER.GAS:
			($SubstanceState as TextureRect).texture = gas_image

		SubstanceData.STATE_OF_MATTER.LIQUID:
			($SubstanceState as TextureRect).texture = liquid_image

		SubstanceData.STATE_OF_MATTER.SOLID:
			($SubstanceState as TextureRect).texture = solid_image

	($VBoxContainer2/Amount as RichTextLabel).text = "[center]%dg[/center]" % [substance.amount]
