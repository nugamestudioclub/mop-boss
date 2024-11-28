class_name InspectableObject
extends RigidBody3D

# OBJECT STATE
var is_inspected := false

# INPUT PARAMETERS
const MOUSE_SENSITIVITY := 0.5
const DEG_PER_PRESS := 3

# Object has entered inspect mode
func enter_inspect_mode():
	is_inspected = true

# Object has exited inspect mode
func exit_inspect_mode():
	is_inspected = false

# Player created an input
func _input(event):
	if not is_inspected: return
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey:
		_handle_event_key(event)

# Player moved their mouse
func _handle_mouse_motion(event):
	if event.button_mask != 0:
		rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY))
		rotate_z(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))

# Player pressed a key
func _handle_event_key(event):
	var input := Vector3.ZERO # create blank vector3
	input.x = Input.get_axis("move_right", "move_left") # returns -1.0 if first, 0.0 if none
	input.z = Input.get_axis("move_back", "move_forward") # returns +1.0 if second, 0.0 if both
	
	rotate_x(deg_to_rad(input.x * DEG_PER_PRESS))
	rotate_z(deg_to_rad(input.z * DEG_PER_PRESS))

# TODO: GHOST CODE... Oooo Spooky
#func _enable_input_listening() -> void:
	#if not get_tree().is_connected("input_event", self, "_on_input_event"):
		#get_tree().connect("input_event", self, "_on_input_event")
#
#func _disable_input_listening() -> void:
	#if get_tree().is_connected("input_event", self, "_on_input_event"):
		#get_tree().disconnect("input_event", self, "_on_input_event")
