extends Puzzle

@onready var knob1 = $Knob1
@onready var knob2 = $Knob2
const KNOB1_RADS_PER_TURN = PI/100
const KNOB2_RADS_PER_TURN = PI/5


func is_altered() -> bool:
	return false

func is_solved() -> bool:
	return false

func on_enter_level() -> void:
	pass

func _on_puzzle_interact(_camera: Camera3D, event: InputEvent, _event_position: Vector3,
		_normal: Vector3, shape_idx: int, collision_object: CollisionObject3D) -> void:
	if not event is InputEventMouseButton: return
	if event.pressed: return
	var radians = 0
	if collision_object == knob1:
		radians = KNOB1_RADS_PER_TURN
	elif collision_object == knob2:
		radians = KNOB2_RADS_PER_TURN
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_RIGHT:
			radians *= -1
	collision_object.rotate_y(radians)
	#if collision_object == knob2:
		#collision_object.rotation.y = clampf(collision_object.rotation.y, 0, -PI+PI/18)
