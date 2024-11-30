extends Evidence

var padlock_variants: Array = G_lock.get_lock_variants("pad_lock")
var chosen_variant: Dictionary
var lock_definitions: Dictionary = preload("res://asset/json/evidence/locks.json").data["definitions"]

var unlocked = false
var dumpster = null

@onready var collision_rod = $collision_rod
@onready var padlock_codes = $Dial/padlock_codes
@onready var pivot = $UnlockPivot
@onready var anchor_point = $AnchorPoint
@onready var delay_timer = $Timer

const NOTCHES: int = 16
const RADS_PER_TURN := TAU / NOTCHES

var correct_combo = [0, 0, 0, 0, 0]
var current_combo = [0, 0, 0, 0, 0]

func _ready() -> void:
	super._ready()
	chosen_variant = padlock_variants.pick_random()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(lock_definitions["colors"][chosen_variant["color"]])
	material.roughness = 0.3
	material.metallic = 0.6
	for child in G_node.get_descendants(self):
		if child is MeshInstance3D and child.name != "padlock_codes":
			child.material_override = material
	
	correct_combo = G_lock.randomize_combo(chosen_variant, 5, NOTCHES)

var cooldown = false
func _input_event_collider(_camera: Camera3D, _event: InputEvent, _event_position: Vector3,
	_normal: Vector3, _shape_idx: int, collision_object: CollisionObject3D) -> void:
	if cooldown == true: return
	cooldown = true
	
	if collision_object != $Dial:
		return  # Ignore input for other objects

	# Spin the dial based on input type
	var dial_delta = RADS_PER_TURN
	var spin_direction = G_lock.get_input_axis("rotate_view_down", "rotate_view_up")
	dial_delta *= spin_direction

	# Rotate the dial and update the combo
	padlock_codes.rotate_x(dial_delta)
	current_combo[-1] = G_lock.update_combo(current_combo, -1, -spin_direction, NOTCHES)
	cooldown = false
	
	# Restart the timer
	delay_timer.start()


func _on_delay_timer_timeout() -> void:
	if unlocked: return
	var current_stage = current_combo[-1]
	var correct_stage = correct_combo[current_combo.size() - 1]
	
	# Check correctness after the delay
	if current_stage == correct_stage:
		# Unlock if the full combo is correct
		if not unlocked and is_solved():
			_unlock()
		
		print("click")
		current_combo.append(current_stage)  # Advance to the next combo
	else:
		print("should be:", correct_stage)
		print("is:", current_stage)
		print("clack")
		
		var distance_right = ((correct_stage - current_stage) + NOTCHES) % NOTCHES
		var distance_left = ((current_stage - correct_stage) + NOTCHES) % NOTCHES
		if distance_right < distance_left:
			print("SFX: sound indicating to the right")
		else:
			print("SFX : sound indicating to the left")
		# binary search, if you know to the right or left can easily figure it out
		#current_combo[-1] = 0  # Reset the current combo position


func _unlock() -> void:
	print("UNLOCK TIME!!!")
	unlocked = true
	
	# Rotate lock out of socket
	var rotate_vector = Vector3(0, 180, 0)
	G_node3d.rotate_around_point(collision_rod, pivot.global_position, rotate_vector)
	collision_rod.position += Vector3(0, 0.1, 0)
	anchor_point.queue_free()
	
	# Unlock dumpster its attached to
	if dumpster and dumpster.has_method("unlock"):
		dumpster.unlock()

func is_solved() -> bool:
	return current_combo == correct_combo
