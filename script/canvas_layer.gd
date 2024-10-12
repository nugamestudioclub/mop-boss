extends CanvasLayer

# Inspect parameters
#var cancel_key = KEY_SPACE
var inspect_button = MOUSE_BUTTON_RIGHT
var default_mouse_mode = Input.MOUSE_MODE_CAPTURED
var inspect_mouse_mode = Input.MOUSE_MODE_VISIBLE

# Highlight parameters
var outline_shader: ShaderMaterial = preload("res://resource/outline_shader.tres")

# Inspected memory
var inspect_group := "inspectable"
var highlight_object: Node3D = null
var target: Node3D = null

var inspected_node: Node3D = null
var inspected_copy: Node3D = null

# Node paths
@onready var player: RigidBody3D = $"../Player"
@onready var camera_player = $"../Player/TwistPivot/PitchPivot/PlayerPov"
@onready var inspector_gui = $Control
@onready var inspected_node_holder = $Control/SubViewportContainer/SubViewport/View/InspectedNode

func _enter_inspect():
	Input.set_mouse_mode(inspect_mouse_mode)
	player.can_move = false
	inspector_gui.show()
	inspected_node = target
	_copy_to_inspect_view(target)
	target.hide()

"""Closes the inspection window, puts object back"""
func _cancel_inspect():
	Input.set_mouse_mode(default_mouse_mode)
	player.can_move = true
	$Control.hide()
	if inspected_node != null:
		inspected_node.show()
	inspected_node = null
	if inspected_copy != null:
		inspected_copy.is_inspected = false
	inspected_copy = null
	for inspected in inspected_node_holder.get_children():
		inspected.queue_free()

"""Sets the outline around an object based on size"""
func _resize_outline(node: Node3D, size: float):
	var outlined := []
	outlined.append_array(node.get_children())
	for child in outlined:
		outlined.append_array(child.get_children())
	for other_node in outlined:
		var shader_copy = outline_shader.duplicate()
		if other_node is CSGShape3D:
			other_node.material.next_pass = shader_copy
			other_node.material.next_pass.set_shader_parameter("size", size)
		elif other_node is MeshInstance3D:
			other_node.material_overlay = shader_copy
			other_node.material_overlay.set_shader_parameter("size", size)

func _remove_outline(node: Node3D): _resize_outline(node, 0)
func _add_outline(node: Node3D): _resize_outline(node, 1.05)

"""Takes a given object and copies it to the inspect viewport""" 
func _copy_to_inspect_view(object):
	inspected_copy = object.duplicate()
	if inspected_copy is RigidBody3D:
		inspected_copy.freeze = true
	_remove_outline(inspected_copy)
	inspected_copy.position = Vector3.ZERO
	var furthest_end := Vector3.ZERO
	var furthest_start := Vector3.ZERO
	for mesh in NodeHelper.get_children_recursive(inspected_copy):
		if not mesh is VisualInstance3D: continue
		var aabb: AABB = mesh.global_transform.affine_inverse() * mesh.get_aabb()
		if aabb.end.length() > furthest_end.length():
			furthest_end = aabb.end
		if aabb.position.length() > furthest_start.length():
			furthest_start = aabb.position
	var biggest_axis = AABB(furthest_start, furthest_end - furthest_start).get_longest_axis_size()
	inspected_copy.scale = inspected_copy.scale.normalized() * biggest_axis * 10.0
	inspected_copy.rotate_x(PI/4)
	inspected_copy.rotate_z(PI/4)
	inspected_copy.rotate_y(PI/2)
	inspected_copy.get_node("CollisionShape3D").disabled = true
	inspected_copy.is_inspected = true
	inspected_node_holder.add_child(inspected_copy)
	
"""Checks if an object is inspectable"""
func _can_inspect(object):
	return (object is Node and 
		object.is_in_group(inspect_group) and 
		object.visible)

func _ready():
	inspector_gui.hide()

func _input(event):
	if event is InputEventMouseMotion:
		# Get the object the mouse is targetting camera
		target = Raycast.get_mouse_target(camera_player)
			
		if highlight_object != target:
			if highlight_object != null:
				_remove_outline(highlight_object)
				highlight_object = null
			if _can_inspect(target) and inspected_node == null:
				_add_outline(target)
				highlight_object = target

	elif event is InputEventMouseButton:
		if event.pressed: return
		
		if event.button_index == inspect_button:
			if inspected_node == null and _can_inspect(target):
				_enter_inspect()

	elif Input.is_action_just_pressed("ui_cancel"):
		if inspector_gui.visible:
			_cancel_inspect()

	elif event is InputEventKey:
		if event.pressed: return
		
		# Support for basic key presses here in the future

func _on_close_button_gui_input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			_cancel_inspect()
