class_name ChemicalBottle
extends Tool

@onready var bottle_body = $Bottle/Bottle_Body

enum Chemical {
	BLEACH,
	ACID,
	TOMATO_JUICE,
	SOAPY_WATER
}

func get_chemical_color(chemical: Chemical):
	var color = null
	match chemical:
		Chemical.BLEACH: color = Color("ddedfd")
		Chemical.ACID: color = Color("90db81")
		Chemical.TOMATO_JUICE: color = Color("a8212f")
		Chemical.SOAPY_WATER: color = Color("fb9391")
	return color



@export var contents: Chemical

func _ready():
	bottle_body.material_override.albedo_color = get_chemical_color(contents)
