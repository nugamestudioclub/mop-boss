class_name Puzzle
extends RigidBody3D

@onready var original_global_position := global_position

var active_tool: Node3D = null

const DISTANCE_TOLERANCE := 1.25
# Don't change this
const DISTANCE_TOLERANCE_SQUARED = pow(DISTANCE_TOLERANCE, 2)

func has_moved() -> bool:
	return original_global_position.distance_squared_to(global_position) < DISTANCE_TOLERANCE_SQUARED

func is_altered() -> bool:
	return false

func is_solved() -> bool:
	return false

func on_enter_level() -> void: # not called when inspected, while _ready is called when inspected
	pass

func _on_puzzle_interact(camera: Camera3D, event: InputEvent, event_position: Vector3,
		normal: Vector3, shape_idx: int, collision_object: CollisionObject3D) -> void:
	pass

var _is_inspected := false

var input_event_reference := {} # Dictionary[CollisionObject3D, Callable]

func _toggle_input_signals(connect_signal: bool):
	for child in NodeHelper.get_descendants(self):
		if not child is CollisionObject3D: continue
		if connect_signal:
			var callable := func(camera, event, event_position, normal, shape_idx):
					_on_puzzle_interact(camera, event, event_position, normal, shape_idx, child)
			child.input_event.connect(callable)
			input_event_reference[child] = callable
		else:
			child.input_event.disconnect(input_event_reference[child])

func _toggle_inspect(node: Node3D):
	if node == self:
		_is_inspected = not _is_inspected
		_toggle_input_signals(_is_inspected)
		for child in get_children():
			if not child is CollisionShape3D: continue
			child.disabled = _is_inspected


func _ready():
	NodeHelper.inspector_canvas_layer_node.toggle_inspect.connect(_toggle_inspect)
