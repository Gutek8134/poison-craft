class_name Substance

extends Resource

@export var data: SubstanceData
@export var amount: int

func _init(p_data: SubstanceData=null, p_amount: int=0):
    data = p_data
    amount = p_amount

func _to_string() -> String:
    return "(Substance) %s: %d" % [data.name, amount]