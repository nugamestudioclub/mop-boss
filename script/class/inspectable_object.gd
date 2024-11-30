class_name InspectableObject
extends RigidBody3D

# OBJECT STATE
var is_inspected := false

# INPUT PARAMETERS
const MOUSE_SENSITIVITY := 0.5
const DEG_PER_PRESS := 3

# INPUT LISTENING MEMORY
var input_event_reference := {}

# Object has entered inspect mode
func enter_inspect_mode():
	is_inspected = true
	_start_input_listening()
	_disable_rigid_colliders()
	print("ENTER INSPECT")

# Object has exited inspect mode
func exit_inspect_mode():
	is_inspected = false
	_stop_input_listening()
	_enable_rigid_colliders()
	print("EXIT INSPECT")

# Start listening for inputs from all object colliders
func _start_input_listening():
	for collider in G_node.get_descendants(self):
		if not collider is CollisionObject3D: continue
		var callable := func(camera, event, event_position, normal, shape_idx):
				_input_event_collider(camera, event, event_position, normal, shape_idx, collider)
		collider.input_event.connect(callable)
		input_event_reference[collider] = callable

# Stop listening for inputs from all object colliders
func _stop_input_listening():
	for collider in G_node.get_descendants(self):
		if not collider is CollisionObject3D: continue
		if not input_event_reference.has(collider): continue
		input_event_reference.erase(collider)
		collider.input_event.disconnect(input_event_reference[collider])

# Player created an input in collision area of object
@warning_ignore("unused_parameter")
func _input_event_collider(
	camera: Camera3D,
	event: InputEvent,
	event_position: Vector3,
	normal: Vector3,
	shape_idx: int,
	collider: CollisionObject3D):
	pass

# Player created an input in general
func _input(event):
	if not is_inspected: return
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventKey:
		_handle_event_key(event)

# Player moved their mouse
func _handle_mouse_motion(event):
	if event.button_mask == 2:
		rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY))
		rotate_z(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))

# Player pressed a key
func _handle_event_key(_event):
	var input := Vector3.ZERO # create blank vector3
	input.x = Input.get_axis("move_right", "move_left") # returns -1.0 if first, 0.0 if none
	input.z = Input.get_axis("move_back", "move_forward") # returns +1.0 if second, 0.0 if both
	
	rotate_x(deg_to_rad(input.x * DEG_PER_PRESS))
	rotate_z(deg_to_rad(input.z * DEG_PER_PRESS))

# Enable rigid body colliders to get in the way
func _enable_rigid_colliders():
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = false

# Stop rigid body colliders from getting in the way
func _disable_rigid_colliders():
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = true
