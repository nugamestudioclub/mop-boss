extends RigidBody3D

# States
@export var can_move: bool = true
@export var sprinting: bool = false

# Camera Parameters
var default_mouse_mode = Input.MOUSE_MODE_CAPTURED
var pause_mouse_mode = Input.MOUSE_MODE_VISIBLE
var jump_trauma = 0.5
var sprint_trauma = 0.4
var walk_trauma = 0.1
var stop_trauma = 0.5

# Movement Parameters
const walk_acceleration: float = 50 # meters / second^2
const jump_velocity: float = 4.5 # meters / second
const walk_velocity: float = 0.5 # meters / second
const sprint_factor: float = 2 

# Movement Input Parameters
var mouse_sensitivity := 0.001
var min_pitch := -60
var max_pitch := 60

var twist_input := 0.0
var pitch_input := 0.0

# Player Objects
@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var camera := $TwistPivot/PitchPivot/Camera
@onready var hand := $TwistPivot/PitchPivot/Hand
@onready var head := $TwistPivot/PitchPivot/Head
@onready var inventory = $Inventory

# Character Properties
@onready var character_height = $CollisionShape3D.shape.height
@onready var player_mass: float = self.mass

"""Checks whether the player is on the floor or falling"""
func is_on_floor():
	# Method #1, shoot a raycast right under player, check if there is an object under
	var raycast_result = G_raycast.raycast_length(position, Vector3.DOWN, character_height/2, [self])
	return raycast_result.has("collider")

# Called when the node enters the scene tree for the **first time.**
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
		var directional_vector: Vector3 = twist_pivot.global_basis * cardinal_direction.normalized()

		walk_force = directional_vector * walk_acceleration
		if sprinting: 
			walk_force *= sprint_factor
			#camera.add_trauma_force(sprint_trauma)
		elif directional_vector != Vector3.ZERO:
			#camera.add_trauma_force(walk_trauma)
			pass
		
		# Pause locking the mouse
		if Input.is_action_just_pressed("ui_cancel"):
			Input.set_mouse_mode(pause_mouse_mode)
		elif Input.is_action_just_released("ui_cancel"):
			Input.set_mouse_mode(default_mouse_mode)
		# Apply a one-time impulse for jump force
		elif Input.is_action_just_pressed("jump") and is_on_floor():
			var jump_force = (Vector3.UP * jump_velocity * player_mass)
			apply_central_impulse(jump_force)
			camera.add_trauma_impulse(jump_trauma)
		# Check if player is sprinting
		elif Input.is_action_just_pressed("sprint"):
			if not sprinting:
				sprinting = true
				print("started sprinting")
				camera.add_trauma_force(sprint_trauma)
		elif Input.is_action_just_released("sprint"):
			if sprinting:
				sprinting = false
				print("stopped sprinting")
				camera.add_trauma_force(-sprint_trauma)
		
		# Rotate charcter based on mouse motion detected previously
		twist_pivot.rotate_y(twist_input)
		pitch_pivot.rotate_x(pitch_input)
		pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, 
			deg_to_rad(min_pitch),
			deg_to_rad(max_pitch))
		
		twist_input = 0.0
		pitch_input = 0.0
	
	# Damp the player / apply net movement
	var damp_acceleration = walk_acceleration * walk_velocity
	var damp_force = Vector3(linear_velocity.x, 0, linear_velocity.z) * damp_acceleration 
	
	# For future reference, apply_central force based on time already, so no * delta
	apply_central_force((walk_force - damp_force) * player_mass)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Calculate amount to twist and pitch character based on mouse motion
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity
