extends CanvasLayer

# Inspect parameters
const DEFAULT_VIEW_FOV = 75
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

# Inspector paths
@onready var inspector_gui = $Control
@onready var inspector_world = inspector_gui.get_node("SubViewportContainer/Viewport/World")
@onready var inspector_camera = inspector_world.get_node("Camera3D")

func _enter_inspect_mode():
	# Player
	Input.set_mouse_mode(inspect_mouse_mode)
	player.can_move = false
	
	# Enable viewport pop-up
	inspector_gui.show()
	inspector_camera.fov = DEFAULT_VIEW_FOV

func _start_inspecting(node: Node3D):
	# Player
	Input.set_mouse_mode(inspect_mouse_mode)
	player.can_move = false
	
	# Save previous state
	_save_state(node)
	
	# Add object
	node.freeze = true
	node.global_position = Vector3.ZERO
	node.reparent(inspector_world)
	
	G_highlight.remove_highlight(node)
	G_node3d.scale_to_fit(node, 1.3)  # 1.3 is a magic number so that all inspected objects are 1.3x some uniform size
	
	# TODO: FIX, this sucks lol
	if node is Puzzle:
		node.active_tool = player.get_node("TwistPivot/PitchPivot/Hand")
	
	# Tell object its inspected
	if node.has_method("_enter_inspect_mode()"):
		node._enter_inspect_mode()

"""Closes the inspection window, puts object back"""
func _exit_inspect_mode():
	# Player
	Input.set_mouse_mode(default_mouse_mode)
	player.can_move = true
	
	# Disable viewport pop-up
	inspector_gui.hide()
	
	# Remove all nodes from inspector
	for node in inspector_world.get_children():
		print(inspector_world.get_children())
		if node.is_in_group(inspect_group):
			_stop_inspecting(node)
			print(node.name)

func _stop_inspecting(node: Node3D):
	# Load previous state
	_load_state(node)
	
	# Tell object its not inspected
	if node.has_method("_exit_inspect_mode()"):
		node._exit_inspect_mode()

"""Checks if an object is inspectable"""
func _is_inspectable(object):
	return (object is Node and 
		object.is_in_group(inspect_group) and 
		object.visible)

func _save_state(object):
	inspected_original_parent[object] = object.get_parent()
	inspected_original_transform[object] = object.transform
	inspected_original_freeze[object] = object.freeze

func _load_state(object):
	object.reparent(inspected_original_parent[object])
	inspected_original_parent[object] = null
	object.transform = inspected_original_transform[object]
	inspected_original_transform[object] = null
	object.freeze = inspected_original_freeze[object]
	inspected_original_transform[object] = null

func _ready():
	inspector_gui.hide()

func _input(event):
	# Attempt highlight
	if event is InputEventMouseMotion:
		target = G_raycast.get_mouse_target(camera_player)
		
		if highlighted_node != target:
			if highlighted_node != null:
				G_highlight.remove_highlight(highlighted_node)
				highlighted_node = null
			if _is_inspectable(target):
				G_highlight.add_highlight(target)
				highlighted_node = target
	
	# Attempt inspect
	elif event is InputEventMouseButton:
		if event.pressed: return
		
		if event.button_index == inspect_button:
			if _is_inspectable(target):
				_enter_inspect_mode()
				_start_inspecting(target)
	
	# Exit inspect	
	elif Input.is_action_just_pressed("ui_cancel"):
		if inspector_gui.visible:
			_exit_inspect_mode()
	
	# Zooming
	elif Input.is_action_just_pressed("zoom_in"):
		inspector_camera.fov = clamp(inspector_camera.fov - 5, 5, DEFAULT_VIEW_FOV)
	elif Input.is_action_just_pressed("zoom_out"):
		inspector_camera.fov = clamp(inspector_camera.fov + 5, 5, DEFAULT_VIEW_FOV)
