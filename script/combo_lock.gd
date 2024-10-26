extends Puzzle

var unlocked = false

const FACES := 16
const DEGREE_PER_TURN := 360/FACES
const RADS_PER_TURN := deg_to_rad(DEGREE_PER_TURN)

func is_altered() -> bool:
	return unlocked

func is_solved() -> bool:
	return false

func on_enter_level() -> void:
	var material = StandardMaterial3D.new()
	material.albedo_color = Color("ff6a00")
	material.roughness = 0.3
	material.metallic = 0.6
	for child in NodeHelper.get_descendants(self):
		if child is MeshInstance3D:
			child.material_override = material

func get_input_axis(posAction: String, negAction):
	var direction = 0
	if Input.is_action_just_pressed(posAction):
		direction = -1
	elif Input.is_action_just_pressed(negAction):
		direction = 1
	return direction

func _on_puzzle_interact(_camera: Camera3D, event: InputEvent, _event_position: Vector3,
	_normal: Vector3, shape_idx: int, collision_object: CollisionObject3D) -> void:

	# Spin the dial based on input type
	var dial_delta = RADS_PER_TURN
	var spin_direction = get_input_axis("rotate_view_down", "rotate_view_up")
	dial_delta *= spin_direction

	if collision_object == $Dials:
		$Dials.get_child(shape_idx).rotate_z(dial_delta)

#func _process(delta: float) -> void:
	#print(Input.get_axis("rotate_view_down", "rotate_view_up"))
	#var spin_direction = Input.get_axis("rotate_view_down", "rotate_view_up")
