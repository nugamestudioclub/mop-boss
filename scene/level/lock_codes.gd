extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		var random_code = ""
		for i in range(randi_range(3, 5)):
			random_code += "%X" % randi_range(0, 15)
		child.text = random_code
