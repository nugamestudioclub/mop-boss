class_name DialPhone
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
func _input(event: InputEvent):
	if not is_inspected: return
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey:
		_handle_event_key(event)

# Player moved their mouse
func _handle_mouse_motion(event: InputEvent):
	if event.button_mask == 2:
		rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY))
		rotate_z(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))



# Player pressed a key
func _handle_event_key(event: InputEvent):
	var input := Vector3.ZERO # create blank vector3
	input.x = Input.get_axis("move_right", "move_left") # returns -1.0 if first, 0.0 if none
	input.z = Input.get_axis("move_back", "move_forward") # returns +1.0 if second, 0.0 if both
	
	rotate_x(deg_to_rad(input.x * DEG_PER_PRESS))
	rotate_z(deg_to_rad(input.z * DEG_PER_PRESS))
	
	if event.keycode == KEY_0:
		var current_scene = get_tree().get_current_scene()
		current_scene.end_level()

@onready var rotary = $Mesh/RotaryDial_low
@onready var rotary_default: Vector3 = rotary.rotation
@onready var plane_reference_1 = $Holes/CollisionShape3D
@onready var plane_reference_2 = $Holes/CollisionShape3D5
@onready var plane_reference_3 = $Holes/CollisionShape3D9
#@onready var plane := Plane(plane_reference_1.position, plane_reference_2.position, plane_reference_3.position)

var moving_hole_index = -1
func _on_holes_input_event(_camera, event, event_position, normal, shape_idx):
	print(is_inspected)
	if not is_inspected: return
	if event is InputEventMouseButton:
		if event.button_index == 0:
			if event.pressed:
				print(shape_idx)
				moving_hole_index = shape_idx
			else:
				moving_hole_index = -1
	elif event is InputEventMouseMotion:
		if moving_hole_index == -1: return
		rotary.rotation = rotary_default
		rotary.rotate(normal, event_position.angle_to(Vector3.ZERO))
