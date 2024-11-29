extends Evidence

var note_options: Array = preload("res://asset/json/evidence/notes.json").data
var erased_words = []

func is_altered() -> bool:
	return false


func is_solved() -> bool:
	return false

func _split_up_text(txt: String) -> Array:
	return Array(txt.split("\n")).map(func(line): return Array(line.split(" ")).filter(func(x: String): return not x.is_empty()))

var random_note: Dictionary
var text: String
var text_lines: Array
var word_positions = []
func on_enter_level() -> void:
	random_note = note_options.pick_random()
	text = random_note.text
	text_lines = _split_up_text(text)
	$MeshInstance3D2/Label3D.text = text
	$Crossout/Image.scale = Vector3(len(text_lines[0][0]) * 0.375, 1, 1)
	
	for i in range(len(text_lines)):
		for j in range(len(text_lines[i])):
			word_positions.append([i, j, _get_position_of_word(i, j)])
	# TODO: or use:
# sudo code
# list of sentence structures: {"I saw the {noun} {verb} the {noun} the other day.}
# dictionary for nouns and verbs: {[noun: "dog", "cat"], [verb: "attacked", "hit"]}
# function loops for each key in dictionary checking if {key} in the randomly
# selected sentence structure, then replaces the first occurence, repeat till you
# have a random sentence.

# made by
# 15AAC
# and
# 5A7E3

var line = 0
var word = 0

func change_line(direction: int):
	var new_line = line + direction
	if new_line < 0 or new_line >= len(text_lines):
		return
	line = new_line
	word = 0


func change_word(direction: int):
	var words = text_lines[line]
	var new_word = word + direction
	if new_word < 0:
		var old_line = line
		change_line(-1)
		if line != old_line:
			word = len(text_lines[line]) - 1
	elif new_word >= len(words):
		change_line(1)
	else:
		word = new_word


func _get_position_of_word(text_line: int, text_word: int):
	var words = text_lines[text_line]
	var word_length = len(words[text_word])
	var chars_before_word = 0
	for i in range(text_word):
		chars_before_word += len(words[i]) + 1
	return Vector3(chars_before_word * 0.0197, 0, text_line * 0.082)


func _move_crossout_to_word():
	# Reset position
	$Crossout.position = crossout_origin
	# Locally (accounting for rotation) move it to the word
	$Crossout.translate_object_local(_get_position_of_word(line, word))
	$Crossout/Image.scale = Vector3(len(text_lines[line][word]) * 0.375, 1, 1)


@onready var crossout_origin = $Crossout.position
func _input(event: InputEvent):
	if event is InputEventKey:
		if not event.pressed or event.echo: return
		match event.keycode:
			KEY_LEFT:
				change_word(-1)
			KEY_RIGHT:
				change_word(1)
			KEY_DOWN:
				change_line(1)
			KEY_UP:
				change_line(-1)
			KEY_SPACE, KEY_DELETE, KEY_BACKSPACE:
				#var old_text = _split_up_text($MeshInstance3D2/Label3D.text)
				#var blank_word = ""
				#var old_word = old_text[line][word]
				#if "\u200e" in old_word: return
				#for i in range(len(old_word)):
					#blank_word += "\u200e"
				#old_text[line][word] = blank_word
				#$MeshInstance3D2/Label3D.text = "\n".join(old_text.map(func(x): return " ".join(x)))
				for erased in erased_words:
					if erased[0] == line and erased[1] == word: return
				var copy = $Crossout.duplicate()
				$PreviouslyCrossedOut.add_child(copy)
				erased_words.append([line, word, text_lines[line][word]])
			_:
				return
		_move_crossout_to_word()


func _on_puzzle_interact(_camera: Camera3D, event: InputEvent, event_position: Vector3,
		normal: Vector3, shape_idx: int, collision_object: CollisionObject3D) -> void:
	#if not event is InputEventMouseButton: return
	#if event.pressed: return # check for button released
	$Crossout.show()
	var nearest = null
	var distance = 0.02
	for word_pos in word_positions:
		$Crossout.position = crossout_origin
		$Crossout.translate_object_local(word_pos[2])
		var new_dist = event_position.distance_squared_to($Crossout.global_position)
		if distance > new_dist:
			distance = new_dist
			nearest = word_pos
	if nearest != null:
		line = nearest[0]
		word = nearest[1]
		_move_crossout_to_word()
	else:
		$Crossout.position = crossout_origin
		$Crossout.hide()
	# TODO: ripping, and forging signatures


func _on_actions_mouse_exited():
	$Crossout.hide()
