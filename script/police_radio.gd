extends Puzzle

@onready var knob1 = $Knob1
@onready var knob2 = $Knob2

const KNOB1_TICKS := 30
const KNOB1_RADS_PER_TURN = TAU/KNOB1_TICKS

const KNOB2_MIN_TICKS := 0
const KNOB2_MAX_TICKS := 5
const KNOB2_RADS_PER_TURN = PI/KNOB2_MAX_TICKS
var KNOB2_TICKS = 0

func is_in_range(value, min_value, max_value) -> bool:
	return value >= min_value and value <= max_value

func is_altered() -> bool:
	return false

func is_solved() -> bool:
	return false

func on_enter_level() -> void:
	pass

func get_input_axis(posAction: String, negAction):
	var direction = 0
	if Input.is_action_just_released(posAction):
		direction = -1
	elif Input.is_action_just_released(negAction):
		direction = 1
	return direction

func _on_puzzle_interact(_camera: Camera3D, event: InputEvent, _event_position: Vector3,
	_normal: Vector3, shape_idx: int, collision_object: CollisionObject3D) -> void:
	
	# Spin the dial based on input type
	var spin_direction = get_input_axis("rotate_view_down", "rotate_view_up")
	var knob_delta = spin_direction
	
	# Rotate dial based on collision object
	if collision_object == knob1:
		knob_delta *= KNOB1_RADS_PER_TURN
	elif collision_object == knob2:
		knob_delta *= KNOB2_RADS_PER_TURN
		
		if is_in_range(KNOB2_TICKS - spin_direction, KNOB2_MIN_TICKS, KNOB2_MAX_TICKS):
			KNOB2_TICKS -= spin_direction
		else:
			knob_delta = 0
	
	collision_object.rotate_y(knob_delta)
