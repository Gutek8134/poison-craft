class_name SubstanceTableNode

extends Node2D

@export var data_table: SubstanceDataTable

func _init():
	data_table = SubstanceDataTable.factory()
