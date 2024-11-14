extends CanvasLayer

# Inspect parameters
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
var inspected_node_parent: Node3D = null
var inspected_copy_transform: Transform3D = Transform3D.IDENTITY
var insepcted_freeze_original = null

# Node paths
@onready var player: RigidBody3D = $"../Player"
@onready var camera_player = $"../Player/TwistPivot/PitchPivot/PlayerPov"
@onready var inspector_gui = $Control
@onready var inspected_node_holder = $Control/SubViewportContainer/SubViewport/View/InspectedNode

signal toggle_inspect(node: Node3D)

# TODO: Fix this function because I hate you godot why not global scale?
"""Scales the inputed node (and any children) to fit within an area (bounds)"""
func _scale_within(node: Node3D, bounds: float): #TODO: change bounds to vector3
	var furthest_end := Vector3.ZERO
	var furthest_start := Vector3.ZERO
	for mesh in node.get_children():
		if not mesh is VisualInstance3D: continue
		var aabb = mesh.get_aabb()
		aabb.position *= mesh.scale
		aabb.end *= mesh.scale
		if aabb.end.length() > furthest_end.length():
			furthest_end = aabb.end
		if aabb.position.length() > furthest_start.length():
			furthest_start = aabb.position
	var biggest_axis = AABB(furthest_start, furthest_end - furthest_start).get_longest_axis_size()
	node.scale = node.scale.normalized() * bounds / biggest_axis

func _enter_inspect():
	Input.set_mouse_mode(inspect_mouse_mode)
	player.can_move = false
	inspector_gui.show()
	inspected_node = target
	_move_to_inspect_view(target)

"""Closes the inspection window, puts object back"""
func _cancel_inspect():
	Input.set_mouse_mode(default_mouse_mode)
	player.can_move = true
	$Control.hide()
	if inspected_node != null:
		toggle_inspect.emit(inspected_node)
	inspected_node.reparent(inspected_node_parent)
	inspected_node.transform = inspected_copy_transform
	
	inspected_node.freeze = insepcted_freeze_original
	
	inspected_node = null

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
func _move_to_inspect_view(object: RigidBody3D):
	inspected_node_parent = object.get_parent()
	inspected_copy_transform = object.transform
	
	insepcted_freeze_original = object.freeze
	object.freeze = true
	
	_remove_outline(object)
	object.global_position = Vector3.ZERO
	_scale_within(object, 1.3)  # 1.3 is a magic number so that all inspected objects are 1.3x some uniform size
	object.reparent(inspected_node_holder)
	toggle_inspect.emit(object)
	
	if object is Puzzle:
		object.active_tool = player.get_node("TwistPivot/PitchPivot/Hand")

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

func _process(delta: float) -> void:
	$fps.text = "FPS: " + str(Engine.get_frames_per_second()) + "   1/delta: " + str(round(1/delta))

func _on_close_button_gui_input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			_cancel_inspect()
