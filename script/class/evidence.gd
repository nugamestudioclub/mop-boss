class_name Evidence
extends InspectableObject

@onready var original_global_position := global_position

var active_tool: Node3D = null

const DISTANCE_TOLERANCE := 1.25
# Don't change this
const DISTANCE_TOLERANCE_SQUARED = pow(DISTANCE_TOLERANCE, 2)

func is_moved() -> bool:
	return original_global_position.distance_squared_to(global_position) < DISTANCE_TOLERANCE_SQUARED

func is_altered() -> bool:
	return false

func is_solved() -> bool:
	return false

# TODO: REMOVE THIS
func on_enter_level() -> void: # not called when inspected, while _ready is called when inspected
	pass
