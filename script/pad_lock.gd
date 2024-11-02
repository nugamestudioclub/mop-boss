extends Puzzle

var unlocked = false

@onready var padlock_rod = $padlock_rod

const FACES: int = 16
const RADS_PER_TURN := TAU/FACES

var correct_combo = [0, 0, 0, 0, 0]
var current_combo = [0, 0, 0, 0, 0]

func _randomize_combo():
	var combo_length = len(correct_combo)
	for i in range(combo_length):
		correct_combo[i] = randi_range(0, FACES - 1)
	print(correct_combo)

func _update_combo(shape_idx, spin_direction: int) -> void:
	var position = current_combo[shape_idx]
	if spin_direction > 0:
		position = (position - 1 + FACES) % FACES  # Increment and wrap around
	elif spin_direction < 0:
		position = (position + 1) % FACES  # Decrement and wrap around
	current_combo[shape_idx] = position

func is_altered() -> bool:
	return unlocked

func is_solved() -> bool:
	return current_combo == correct_combo

func on_enter_level() -> void:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color("ff6a00")
	material.roughness = 0.3
	material.metallic = 0.6
	for child in NodeHelper.get_descendants(self):
		if child is MeshInstance3D:
			child.material_override = material
	
	_randomize_combo()

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
	var dial_delta = RADS_PER_TURN
	var spin_direction = get_input_axis("rotate_view_down", "rotate_view_up")
	dial_delta *= spin_direction

	# Spin the dial if there is one
	if collision_object == $Dial:
		$Dial.get_child(shape_idx).rotate_x(dial_delta)
	
	_update_combo(shape_idx, spin_direction)
	
	# Unlock if not already
	if not unlocked and is_solved():
		unlocked = true
		
		padlock_rod.rotate_y(90)

#func _process(delta: float) -> void:
	#print(Input.get_axis("rotate_view_down", "rotate_view_up"))
	#var spin_direction = Input.get_axis("rotate_view_down", "rotate_view_up")
