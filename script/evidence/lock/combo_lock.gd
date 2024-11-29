extends Evidence

var unlocked = false
var dumpster = null

var combolock_variants: Array = G_lock.get_lock_variants("combo_lock_5_digits")
var chosen_variant: Dictionary
var lock_definitions: Dictionary = preload("res://asset/json/evidence/locks.json").data["definitions"]

#@onready var combo_rod = $LockPivot/combo_rod
@onready var collision_rod = $collision_rod
@onready var pivot = $UnlockPivot
@onready var anchor_point = $AnchorPoint

const FACES: int = 16
const RADS_PER_TURN := PI/FACES

var correct_combo = [0, 0, 0, 0, 0]
var current_combo = [0, 0, 0, 0, 0]

func is_altered() -> bool:
	return unlocked

func is_solved() -> bool:
	return current_combo == correct_combo

func on_enter_level() -> void:
	chosen_variant = combolock_variants.pick_random()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(lock_definitions["colors"][chosen_variant["color"]])
	material.roughness = 0.3
	material.metallic = 0.6
	# TODO: overriding textures, problematic
	for child in G_node.get_descendants(self):
		if child is MeshInstance3D:
			child.material_override = material
	
	correct_combo = G_lock.randomize_combo(chosen_variant, 5, FACES)

func _input_event_collider(_camera: Camera3D, event: InputEvent, _event_position: Vector3,
	_normal: Vector3, shape_idx: int, collision_object: CollisionObject3D) -> void:

	# Spin the dial based on input type
	var dial_delta = RADS_PER_TURN
	var spin_direction = G_lock.get_input_axis("rotate_view_down", "rotate_view_up")
	dial_delta *= spin_direction

	# Spin the dial if there is one
	if collision_object == $Dials:
		$Dials.get_child(shape_idx).rotate_z(dial_delta)
	
		current_combo[shape_idx] = G_lock.update_combo(current_combo, shape_idx, spin_direction, FACES)
	
	# Unlock if not already
	if not unlocked and is_solved():
		unlocked = true
		
		#combo_rod.rotate_y(PI)
		var rotate_vector = Vector3(0, 180, 0)
		G_node.rotate_around_point(collision_rod, pivot.global_position, rotate_vector)
		collision_rod.position += Vector3(0, 0.1, 0)
		
		anchor_point.queue_free()

#func _process(delta: float) -> void:
	#print(Input.get_axis("rotate_view_down", "rotate_view_up"))
	#var spin_direction = Input.get_axis("rotate_view_down", "rotate_view_up")
