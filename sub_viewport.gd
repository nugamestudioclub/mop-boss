extends SubViewport


var MOUSE_SENSITIVITY := 0.5
var degree_per_press := 3

@onready var inspect_node = $View/InspectedNode

func _input(event):
	if inspect_node.get_child_count() == 0:return
	if event is InputEventMouseMotion:
		if event.button_mask != 0:
			inspect_node.get_child(0).rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY))
			inspect_node.get_child(0).rotate_z(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
	elif event is InputEventKey:
		var input := Vector3.ZERO # create blank vector3
		input.x = Input.get_axis("move_right", "move_left") # returns -1.0 if first, 0.0 if none
		input.z = Input.get_axis("move_back", "move_forward") # returns +1.0 if second, 0.0 if both
		
		inspect_node.get_child(0).rotate_x(deg_to_rad(input.x * degree_per_press))
		inspect_node.get_child(0).rotate_z(deg_to_rad(input.z * degree_per_press))
