extends Area3D


func _on_input_event(_camera, event, _event_position, _normal, shape_idx):
	if not event is InputEventMouseButton: return
	if event.pressed: return # check for button released
	var radians := TAU/10 # TAU is 2 * PI
	match event.button_index: # this is comaring the button index to everything in the match statement
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_RIGHT:
			radians *= -1
	if get_parent().is_inspected:
		get_child(shape_idx).rotate_x(radians)
