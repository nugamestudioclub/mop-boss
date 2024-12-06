extends RigidBody3D # like a class, gives access to all functions of rigid body

# RigidBody
@export var can_move: bool = true
@export var sprinting: bool = false
@export var start_reversed: bool = false

# Camera parameters
var default_mouse_mode = Input.MOUSE_MODE_CAPTURED
var pause_mouse_mode = Input.MOUSE_MODE_VISIBLE

# Player movement parameters
const walk_acceleration: float = 50 # meters / second^2
const jump_velocity: float = 4.5 # meters / second
const walk_velocity: float = 0.5 # meters / second
const sprint_factor: float = 2 

var mouse_sensitivity := 0.001
var min_pitch := -60
var max_pitch := 60

var twist_input := 0.0
var pitch_input := 0.0

# Basically waitForChild()
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var camera := $TwistPivot/PitchPivot/PlayerPov
@onready var hand := $TwistPivot/PitchPivot/Hand

var target: Node3D = null

# Character properties
@onready var character_height = $CollisionShape3D.shape.height
@onready var player_mass: float = self.mass

# Dot product is_on_floor parameters
const max_jump_angle = 45
const min_dot_product =  cos(deg_to_rad(max_jump_angle))

"""Checks whether the player is on the floor or falling"""
func is_on_floor():
	# Method #1, shoot a raycast right under player, check if there is an object under
	var raycast_result = G_raycast.raycast_length(position, Vector3.DOWN, character_height/2, [self])
	return raycast_result.has("collider")
	
	# Method #2, get normals of objects player is touching (check if it's flat)
	#var state = PhysicsServer3D.body_get_direct_state(get_rid())
	#var on_floor = false
	#var i := 0
	#while i < state.get_contact_count():
		#var normal := state.get_contact_local_normal(i)
		## The dot product is equal to cos of the desired angle (cos of 45 degrees = 0.7)
		#on_floor = normal.dot(Vector3.UP) > min_dot_product #  1.0 UP / 0.0 SIDE / -1.0 DOWN 
		#if on_floor: break 
		#i += 1
	#return on_floor

# Called when the node enters the scene tree for the **first time.**
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # sets default mouse to locked
	#if start_reversed:
		#$TwistPivot/PitchPivot.rotate_y(PI)

# Called every frame. (delta: float) is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var walk_force = Vector3.ZERO
	if can_move:
		# Get direction player wants to move in based on input
		# For get_axis: returns -1.0 if first, +1.0 if second, 0.0 if none OR both
		var cardinal_direction := Vector3.ZERO
		cardinal_direction.x = Input.get_axis("move_left", "move_right")
		cardinal_direction.z = Input.get_axis("move_forward", "move_back")
		
		# Calculate movement direction relative to twist_pivot | normalized to fix diagonal
		# Use the mass and acceleration to calculate force | F = ma
		var directional_vector: Vector3 = twist_pivot.basis * cardinal_direction.normalized()

		walk_force = directional_vector * walk_acceleration
		if sprinting: walk_force *= sprint_factor
		
		# Pause locking the mouse
		if Input.is_action_just_pressed("ui_cancel"):
			Input.set_mouse_mode(pause_mouse_mode)
		elif Input.is_action_just_released("ui_cancel"):
			Input.set_mouse_mode(default_mouse_mode)
		# Apply a one-time impulse for jump force
		elif Input.is_action_just_pressed("jump") and is_on_floor():
			var jump_force = (Vector3.UP * jump_velocity * player_mass)
			apply_central_impulse(jump_force)
		# Check if player is sprinting
		elif Input.is_action_just_pressed("sprint"):
			sprinting = true
		elif Input.is_action_just_released("sprint"):
			sprinting = false
		
		# Rotate charcter based on mouse motion detected previously
		twist_pivot.rotate_y(twist_input)
		pitch_pivot.rotate_x(pitch_input)
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, 
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch))
			#pitch_pivot.rotate_x(pitch_input)
			#pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, 
				#deg_to_rad(min_pitch),
				#deg_to_rad(max_pitch))
		
		twist_input = 0.0
		pitch_input = 0.0
	
	# Damp the player / apply net movement
	var damp_acceleration = walk_acceleration * walk_velocity
	var damp_force = Vector3(linear_velocity.x, 0, linear_velocity.z) * damp_acceleration 
	
	# For future reference, apply_central force based on time already, so no * delta
	apply_central_force((walk_force - damp_force) * player_mass)
	
	# Debug velocity
	#print("CURR_VELOCITY: ", self.linear_velocity.length())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Calculate amount to twist and pitch character based on mouse motion
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity
