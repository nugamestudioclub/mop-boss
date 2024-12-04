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
var current_combo = [0]

signal on_unlock()

func _ready() -> void:
	chosen_variant = padlock_variants.pick_random()
	var color = chosen_variant["color"]
	G_lock.create_specific_pattern_of_color(color, self)
	
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
	delay_timer.stop()
	delay_timer.start()

func enter_inspect_mode():
	super.enter_inspect_mode()
	if active_tool is Tool and active_tool.type == Tool.Type.HAMMER and chosen_variant.get("special", "") == "use_hammer":
		current_combo = correct_combo
		get_tree().current_scene.get_node("InspectLayer").exit_inspect_mode()

#func _unhandled_key_input(event: InputEvent):
	#if event.is_pressed(): return
	#match event.keycode:
		#KEY_1:
			#$CorrectClick.play()
			#print("hi")
		#KEY_2:
			#$RandomClick.play()

func _on_delay_timer_timeout() -> void:
	if unlocked: return
	var current_stage = current_combo[-1]
	var correct_stage = correct_combo[current_combo.size() - 1]
	
	print("timer triggered")
	# Check correctness after the delay
	if current_stage == correct_stage:
		# Unlock if the full combo is correct
		if not unlocked and is_solved():
			_unlock()
			return
		
		print("click")
		$CorrectClick.play()
		current_combo.append(current_stage)  # Advance to the next combo
		print("current combo: ", current_combo)
	else:
		var special: String = chosen_variant.get("special", "")
		var is_right = special == "listen_click_right"
		var is_left = special == "listen_click_left"
		if not (is_left or is_right): return
		print("should be:", correct_stage)
		print("is:", current_stage)
		print("clack")
		var distance_right = ((correct_stage - current_stage) + NOTCHES) % NOTCHES
		var distance_left = ((current_stage - correct_stage) + NOTCHES) % NOTCHES
		if distance_right < distance_left:
			if is_left:
				$LeftClick.play()
				print("SFX")
			else:
				$RightClick.play()
			print("SFX: sound indicating to the right")
		else:
			if not is_left:
				$LeftClick.play()
				print("SFX")
			else:
				$RightClick.play()
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
	on_unlock.emit()

func is_solved() -> bool:
	return current_combo == correct_combo
