extends CanvasLayer

# Inventory Objects
@onready var inspect = $Control/SubViewportContainer/Viewport/World/Inspect
@onready var tool = $Control/SubViewportContainer/Viewport/World/Tool
@onready var world_camera = $"Control/SubViewportContainer/Viewport/World/Camera"
@onready var store_sound = $"StoreSound"

@onready var player = self.get_owner()

# States
var is_open = false
var target = null
var highlighted = null

# Inspect parameters
const DEFAULT_FOV = 75
const ZOOM_INCREMENT = 1
var inspect_button = MOUSE_BUTTON_RIGHT
var default_mouse_mode = Input.MOUSE_MODE_CAPTURED
var inspect_mouse_mode = Input.MOUSE_MODE_VISIBLE

"""Opens the inspect viewport"""
func open_inventory():
	# Add object in hand if there is any
	var held_object = player.hand.get_primary_held()
	player.hand.stop_holding_all()
	if inspect.is_inspectable(held_object):
		inspect.start_inspecting(held_object)
	
	# Player
	is_open = true
	Input.set_mouse_mode(inspect_mouse_mode)
	player.can_move = false
	
	# Enable viewport pop-up
	self.show()
	world_camera.fov = DEFAULT_FOV
	store_sound.play()

"""Closes the inspect viewport, removes all objects"""
func close_inventory():
	# Player
	is_open = false
	Input.set_mouse_mode(default_mouse_mode)
	player.can_move = true
	
	# Disable viewport pop-up
	self.hide()
	
	# Remove all nodes from inspector
	for object in inspect.get_children():
		inspect.stop_inspecting(object)
		player.hand.start_holding(object)
	store_sound.play()

func _input(_event):
	# Exit inspect	
	if Input.is_action_just_pressed("inventory"):
		if is_open:
			close_inventory()
		else:
			open_inventory()
	
	# Zooming
	elif Input.is_action_just_pressed("zoom_in"):
		var new_fov = world_camera.fov - ZOOM_INCREMENT
		world_camera.fov = clamp(new_fov, ZOOM_INCREMENT, DEFAULT_FOV)
	elif Input.is_action_just_pressed("zoom_out"):
		var new_fov = world_camera.fov + ZOOM_INCREMENT
		world_camera.fov = clamp(new_fov, ZOOM_INCREMENT, DEFAULT_FOV)
	
	# Only runs past this point if inventory closed
	if is_open: return
	
	## Attempt highlight
	#var exclude = []
	##if hand_player.held_object: exclude.append(hand_player.held_object)
	#target = G_raycast.get_mouse_target(player.camera, exclude)
	#
	#if highlighted != target and target != null:
		#if highlighted != null:
			##G_highlight.remove_highlight(highlighted_node)
			#highlighted = null
		#if target.is_in_group("holdable") and target.visible:
			##G_highlight.add_highlight(target)
			#highlighted = target

func _ready() -> void:
	self.hide()
