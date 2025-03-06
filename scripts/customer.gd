class_name Customer

extends Node2D


var expected_effects: Array
var escape_needed: bool
## In seconds
var escape_time: int = 0
var tolerance: float = 1.0
var offered_purchase_price: int
var customer_type: String
var customer_name: String

static func generate_random_customer() -> Customer:
    const customer_scene: PackedScene = preload("res://scenes/customer.tscn")
    const customer_names = ["Bob"]

    # TODO: add more
    var customer_ranges = \
    {
        "Aristocrat": CustomerRange.new(0.15, Pair.new(40, 800), Pair.new(0.05, 0.2), Pair.new(500, 2000), {}, Pair.new(1, 3))
    }
    var customer_sprites = \
    {
        "Aristocrat": preload("res://content/images/plus-t.png")
    }

    var new_customer: Customer = customer_scene.instantiate() as Customer
    new_customer.customer_type = customer_ranges.keys().pick_random()
    var customer_range: CustomerRange = customer_ranges[new_customer.customer_type]

    (new_customer.get_node("Sprite2D") as Sprite2D).texture = customer_sprites[new_customer.customer_type]
    new_customer.customer_name = customer_names.pick_random()

    new_customer.escape_needed = randf() < customer_range.escape_needed
    if new_customer.escape_needed:
        new_customer.escape_time = randi_range(customer_range.escape_time.first, customer_range.escape_time.second)
        
    new_customer.tolerance = randf_range(customer_range.tolerance.first, customer_range.tolerance.second)
    new_customer.offered_purchase_price = randi_range(customer_range.offered_purchase_price.first, customer_range.offered_purchase_price.second)

    var number_of_expected_effects = randi_range(customer_range.number_of_effects.first, customer_range.number_of_effects.second)
    if number_of_expected_effects >= len(customer_range.expected_effects.keys()):
        new_customer.expected_effects = customer_range.expected_effects.keys()
    else:
        new_customer.expected_effects = []
        var effects_weight: int = 0
        for weight in customer_range.expected_effects.values():
            effects_weight += weight
        
        # Choose appropriate number of effects to expect, based on CustomerRange expected_effects distribution
        for i in range(number_of_expected_effects):
            var rnd: int = randi_range(0, effects_weight)
            var total: int = 0
            for effect in customer_range.expected_effects:
                total += customer_range.expected_effects[effect]
                if total >= rnd:
                    new_customer.expected_effects.append(effect)
                    effects_weight -= customer_range.expected_effects[effect]
                    customer_range.expected_effects.erase(effect)
                    break
        
    return new_customer

func _to_string() -> String:
    return "%s (%s): I need something with effects: %s. %s. My tolerance is %.2f, and I will pay %s!" % [
                customer_name,
                customer_type,
                ", ".join(expected_effects),
                "I need %s seconds to get away with it" % [escape_time] if escape_needed else "I don't need to escape",
                tolerance,
                offered_purchase_price
            ]

class CustomerRange:
    ## distribution - dictionary of chances; string->int; can sum up to anything, not needed to normalize
    var expected_effects: Dictionary
    ## min-max; int
    var number_of_effects: Pair
    ## chance; float
    var escape_needed: float
    ## min-max; int in seconds
    var escape_time: Pair
    ## min-max; float must be between 0 and 1
    var tolerance: Pair
    ## min-max; int
    var offered_purchase_price: Pair
        
    func _init(_escape_needed: float, _escape_time: Pair, _tolerance: Pair, _offered_purchase_price: Pair, _expected_effects: Dictionary, _number_of_effects: Pair) -> void:
        escape_needed = _escape_needed
        escape_time = _escape_time
        tolerance = _tolerance
        offered_purchase_price = _offered_purchase_price
        expected_effects = _expected_effects
        number_of_effects = _number_of_effects
