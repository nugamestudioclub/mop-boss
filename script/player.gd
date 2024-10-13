extends RigidBody3D # like a class, gives access to all functions of rigid body

# RigidBody
@export var can_move: bool = true
@export var sprinting: bool = false

# Camera parameters
var default_mouse_mode = Input.MOUSE_MODE_CAPTURED
var pause_mouse_mode = Input.MOUSE_MODE_VISIBLE

# Player movement parameters
const walk_acceleration: float = 14 # meters / second^2
var player_damp: float = 7 # meters / second^2
const jump_velocity: float = 4.5 # meters / second
var player_mass: float = self.mass

var mouse_sensitivity := 0.001
var min_pitch := -60
var max_pitch := 60

var twist_input := 0.0
var pitch_input := 0.0

# Basically waitForChild()
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var player_pov := $TwistPivot/PitchPivot/PlayerPov

# Player inspect parameters
@onready var inspect_view = $"../InspectView"
@onready var inspected_node_holder = inspect_view.inspected_node_holder
@onready var inspector_gui = inspect_view.inspector_gui

var target: Node3D = null
@onready var highlight_object = inspect_view.highlight_object
@onready var inspected_node = inspect_view.inspected_node
@onready var inspect_group = inspect_view.inspect_group

@onready var character_height = $CollisionShape3D.shape.height

const max_jump_angle = 45
const min_dot_product =  cos(deg_to_rad(max_jump_angle))

# Adapted from https://forum.godotengine.org/t/how-to-check-if-rigid-body-is-on-floor/65679
"""Checks whether the player is on the floor or falling"""
func is_on_floor():
	# var raycast_result = Raycast.raycast_length(position, Vector3.DOWN, character_height/2, [self])
	# return raycast_result.has("collider")
	var state = PhysicsServer3D.body_get_direct_state(get_rid())
	var on_floor = false
	var i := 0
	while i < state.get_contact_count():
		var normal := state.get_contact_local_normal(i)
		# The dot product is equal to cos of the desired angle (cos of 45 degrees = 0.7)
		on_floor = normal.dot(Vector3.UP) > min_dot_product #  1.0 UP / 0.0 SIDE / -1.0 DOWN 
		if on_floor: break 
		i += 1
	return on_floor

# Called when the node enters the scene tree for the **first time.**
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # sets default mouse to locked

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_move:
		var cardinal_direction := Vector3.ZERO # create blank vector3
		cardinal_direction.x = Input.get_axis("move_left", "move_right") # returns -1.0 if first, 0.0 if none
		cardinal_direction.z = Input.get_axis("move_forward", "move_back") # returns +1.0 if second, 0.0 if both
		
		# Uses twist_pivot to change movement relative to pivot of the rotated twist
		
		var directional_vector: Vector3 = twist_pivot.basis * cardinal_direction.normalized() # normalized to fix issue of faster diagonal
		var move_force: float = (player_mass * walk_acceleration) # F = ma
		print(delta)
		# (0.5 * 1) so 0.5 acceleration force applied per second
		
		var walk_force = directional_vector * move_force # no apply delta, central force already time
		if sprinting: walk_force *= 1.25
		
		var damp_force = Vector3(linear_velocity.x, 0, linear_velocity.z) * player_damp 
		# damp * walk_speed = move_force | damp = move_force/walk_speed
		
		apply_central_force(walk_force - damp_force)
		
		print("VELO", self.linear_velocity.length())
		
		# Pauses locking the mouse
		if Input.is_action_just_pressed("ui_cancel"):
			Input.set_mouse_mode(pause_mouse_mode)
		elif Input.is_action_just_released("ui_cancel"):
			Input.set_mouse_mode(default_mouse_mode)
		elif Input.is_action_just_pressed("jump") and is_on_floor():
			var jump_force = (Vector3.UP * jump_velocity * player_mass)
			apply_central_impulse(jump_force)
		elif Input.is_action_just_pressed("sprint"):
			sprinting = true
		elif Input.is_action_just_released("sprint"):
			sprinting = false
			
		twist_pivot.rotate_y(twist_input)
		pitch_pivot.rotate_x(pitch_input)
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, 
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch))
		twist_input = 0.0
		pitch_input = 0.0
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Handle twist and pitch movement of camera
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity
