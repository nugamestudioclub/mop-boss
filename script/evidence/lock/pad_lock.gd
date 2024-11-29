extends Evidence

var padlock_variants: Array = G_lock.get_lock_variants("pad_lock")
var chosen_variant: Dictionary
var lock_definitions: Dictionary = preload("res://asset/json/evidence/locks.json").data["definitions"]

var unlocked = false
var dumpster = null

#@onready var padlock_rod = $padlock_rod
@onready var collision_rod = $collision_rod
@onready var padlock_codes = $Dial/padlock_codes
@onready var pivot = $UnlockPivot
@onready var anchor_point = $AnchorPoint

const NOTCHES: int = 40
const RADS_PER_TURN := PI/NOTCHES

var correct_combo = [0, 0, 0, 0, 0]
var current_combo = [0]

func is_altered() -> bool:
	return unlocked

func is_solved() -> bool:
	return current_combo == correct_combo

func on_enter_level() -> void:
	chosen_variant = padlock_variants.pick_random()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(lock_definitions["colors"][chosen_variant["color"]])
	material.roughness = 0.3
	material.metallic = 0.6
	# TODO: overriding textures, problematic
	for child in G_node.get_descendants(self):
		if child is MeshInstance3D and child.name != "padlock_codes":
			child.material_override = material
	
	correct_combo = G_lock.randomize_combo(chosen_variant, 5, NOTCHES)


func _on_puzzle_interact(_camera: Camera3D, event: InputEvent, _event_position: Vector3,
	_normal: Vector3, shape_idx: int, collision_object: CollisionObject3D) -> void:

	# Spin the dial based on input type
	var dial_delta = RADS_PER_TURN
	var spin_direction = G_lock.get_input_axis("rotate_view_down", "rotate_view_up")
	dial_delta *= spin_direction

	# Spin the dial if there is one
	if collision_object == $Dial:
		padlock_codes.rotate_x(dial_delta)
	
	current_combo[-1] = G_lock.update_combo(current_combo, -1, spin_direction, NOTCHES)
	
	# Unlock if not already
	if not unlocked and is_solved():
		unlocked = true
		
		#collision_rod.rotate_y(PI)
		var rotate_vector = Vector3(0, 180, 0)
		G_node.rotate_around_point(collision_rod, pivot.global_position, rotate_vector)
		collision_rod.position += Vector3(0, 0.1, 0)
		
		anchor_point.queue_free()
		# in the future, can add code that checks for all ancestors ->
		# changes dumpster lids to be unlocked / holdable so player can open them
		print("UNLOCK")
		print(dumpster)
		if dumpster and dumpster.has_method("unlock"):
			print("SHOULD UNLOCK")
			dumpster.unlock()
	
	# future implementation, only check if it matches after the lock has been at position
	# for more than say 0.5 seconds, then play a click / sound corresponding to
	# how close it is to correct, also reset currnt_combo if incorrect I assume
	if not unlocked and current_combo[-1] == correct_combo[current_combo.size() - 1]:
		print("WOOOOHOO")
		current_combo.append(current_combo[-1])

#func _process(delta: float) -> void:
	#print(Input.get_axis("rotate_view_down", "rotate_view_up"))
	#var spin_direction = Input.get_axis("rotate_view_down", "rotate_view_up")
