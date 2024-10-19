extends Puzzle

func is_altered() -> bool:
	return false

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

var RADS_PER_TURN := TAU/16 # TAU is 2 * PI
func _on_puzzle_interact(_camera: Camera3D, event: InputEvent, _event_position: Vector3,
		_normal: Vector3, shape_idx: int, collision_object: CollisionObject3D) -> void:
	if not event is InputEventMouseButton: return
	if event.pressed: return # check for button released
	var radians = RADS_PER_TURN
	match event.button_index: # this is comaring the button index to everything in the match statement
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_RIGHT:
			radians *= -1
	if collision_object == $Dials:
		$Dials.get_child(shape_idx).rotate_z(radians)
