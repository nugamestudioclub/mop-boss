extends CanvasLayer

# Inspect parameters
const DEFAULT_FOV = 75
const ZOOM_INCREMENT = 5
var inspect_button = MOUSE_BUTTON_RIGHT
var default_mouse_mode = Input.MOUSE_MODE_CAPTURED
var inspect_mouse_mode = Input.MOUSE_MODE_VISIBLE
var inspect_group := "inspectable"

# Inspected memory
var target: Node3D = null
var highlighted_node: Node3D = null
var inspected_original_parent: Dictionary = {}
var inspected_original_transform: Dictionary = {}
var inspected_original_freeze: Dictionary = {}

# Player paths
@onready var player: RigidBody3D = $"../Player"
@onready var camera_player = player.get_node("TwistPivot/PitchPivot/PlayerPov")
@onready var hand_player = player.get_node("TwistPivot/PitchPivot/Hand")

# Inspector paths
@onready var inspector_gui = $Control
@onready var inspector_world = inspector_gui.get_node("SubViewportContainer/Viewport/World")
@onready var world_inspecting = inspector_world.get_node("Inspecting")
@onready var world_camera = inspector_world.get_node("Camera3D")

"""Opens the inspect viewport"""
func _enter_inspect_mode():
	# Player
	Input.set_mouse_mode(inspect_mouse_mode)
	player.can_move = false
	
	# Enable viewport pop-up
	inspector_gui.show()
	world_camera.fov = DEFAULT_FOV

"""Moves object to inspect view saving previous state"""
func _start_inspecting(node: Node3D):
	# Player
	Input.set_mouse_mode(inspect_mouse_mode)
	player.can_move = false
	
	# Save previous state
	_save_state(node)
	
	# Add object
	node.freeze = true
	node.global_position = Vector3.ZERO
	node.reparent(world_inspecting)
	
	G_highlight.remove_highlight(node)
	G_node3d.scale_to_fit(node, 1.3)  # 1.3 is a magic number so that all inspected objects are 1.3x some uniform size
	
	if node is Evidence:
		node.active_tool = player.hand.held_object
		player.hand.force_stop_holding_hand()
	
	# Tell object its inspected
	if node.has_method("enter_inspect_mode"):
		node.enter_inspect_mode()

"""Closes the inspect viewport, removes all objects"""
func _exit_inspect_mode():
	# Player
	Input.set_mouse_mode(default_mouse_mode)
	player.can_move = true
	
	# Disable viewport pop-up
	inspector_gui.hide()
	
	# Remove all nodes from inspector
	for node in world_inspecting.get_children():
		_stop_inspecting(node)

"""Moves object from inspect window into previous state"""
func _stop_inspecting(node: Node3D):
	# Load previous state
	_load_state(node)
	
	# Tell object its not inspected
	if node.has_method("exit_inspect_mode"):
		node.exit_inspect_mode()

"""Checks if an object is inspectable"""
func _is_inspectable(object):
	return (object is InspectableObject and object.visible)

#func _is_inspectable(object):
	#return (object is RigidBody3D and 
		#object.is_in_group(inspect_group) and 
		#object.visible)

func _save_state(object):
	inspected_original_parent[object] = object.get_parent()
	inspected_original_transform[object] = object.transform
	inspected_original_freeze[object] = object.freeze

func _load_state(object):
	object.reparent(inspected_original_parent[object])
	inspected_original_parent.erase(object)
	object.transform = inspected_original_transform[object]
	inspected_original_transform.erase(object)
	object.freeze = inspected_original_freeze[object]
	inspected_original_transform.erase(object)

func _ready():
	inspector_gui.hide()

func _input(event):
	# Attempt highlight
	var exclude = []
	if hand_player.held_object: exclude.append(hand_player.held_object)
	target = G_raycast.get_mouse_target(camera_player, exclude)
	
	if highlighted_node != target:
		if highlighted_node != null:
			G_highlight.remove_highlight(highlighted_node)
			highlighted_node = null
		if _is_inspectable(target):
			G_highlight.add_highlight(target)
			highlighted_node = target
	
	# Attempt inspect
	if event is InputEventMouseButton:
		if event.pressed: return
		
		if event.button_index == inspect_button:
			if _is_inspectable(target):
				_enter_inspect_mode()
				_start_inspecting(target)
	
	# Exit inspect	
	elif Input.is_action_just_released("ui_cancel"):
		if inspector_gui.visible:
			_exit_inspect_mode()
	
	# Zooming
	elif Input.is_action_just_pressed("zoom_in"):
		var new_fov =world_camera.fov - ZOOM_INCREMENT
		world_camera.fov = clamp(new_fov, ZOOM_INCREMENT, DEFAULT_FOV)
	elif Input.is_action_just_pressed("zoom_out"):
		var new_fov = world_camera.fov + ZOOM_INCREMENT
		world_camera.fov = clamp(new_fov, ZOOM_INCREMENT, DEFAULT_FOV)
