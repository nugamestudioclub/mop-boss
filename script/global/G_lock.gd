extends Node


var lock_definitions: Dictionary = preload("res://asset/json/evidence/locks.json").data["definitions"]
#@onready var alley_level = get_tree().current_scene #$"/root/AlleyLevel"


func get_lock_variants(lock_name: String) -> Array:
	return preload("res://asset/json/evidence/locks.json").data["locks"].filter(func(x): return x["name"] == lock_name)[0]["variants"]


func randomize_combo(chosen_variant: Dictionary, combo_length: int, notches: int) -> Array:
	var new_combo = []
	for i in range(combo_length):
		new_combo.append(randi_range(0, notches - 1))
	var hex_code: String
	var location: String
	if "numbers" in chosen_variant:
		# This is the usual variant
		location = lock_definitions["hidden_number_codes"][chosen_variant["numbers"]]
		hex_code = "".join(new_combo.map(func(x: int): return "%X" % x))
	elif "const" in chosen_variant:
		# These always have the same code
		hex_code = chosen_variant["const"]
		new_combo = Array(hex_code.split()).map(func(x): return x.hex_to_int())
		return new_combo
	elif "special" in chosen_variant:
		# You solve these locks without a code, such as picking the lock
		return new_combo
	if "modifier" in chosen_variant:
		# This one adds some value called "modifier" to each
		# of the digits in the code written on the wall
		var modifier: int = chosen_variant["modifier"]
		print("what is on the wall: ", new_combo)
		new_combo = new_combo.map(func(x): return (x + modifier + notches) % notches)
		print("what is correct: ", new_combo)
	if "order" in chosen_variant:
		# Some variants have different orderings for the lock code
		match chosen_variant["order"]:
			"reverse":
				hex_code = hex_code.reverse()
			"ascending":
				new_combo.sort()
			"descending":
				new_combo.sort()
				new_combo.reverse()
			_: pass
	if location != null:
		# TODO: FIX? kind of annoying to get current scene everytime
		var alley_level = get_tree().current_scene
		alley_level.get_node("LockCodes/" + location).text = hex_code
	#print("Correct: ", new_combo, chosen_variant)
	#print("Location: ", location)
	return new_combo


func get_input_axis(negAction: String, posAction: String):
	var direction = 0
	if Input.is_action_just_released(negAction):
		direction = -1
	elif Input.is_action_just_released(posAction):
		direction = 1
	return direction


func update_combo(current_combo: Array, shape_idx, spin_direction: int, maximum: int) -> int:
	var position = current_combo[shape_idx]
	if spin_direction > 0:
		position = (position - 1 + maximum) % maximum  # Increment and wrap around
	elif spin_direction < 0:
		position = (position + 1) % maximum  # Decrement and wrap around
	return position
