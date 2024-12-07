extends Evidence

var note_options: Array = preload("res://asset/json/evidence/notes.json").data
var erased_words := []
var cut := 100
var trashed := false

func is_altered() -> bool:
	return not erased_words.is_empty() or cut < 100 or trashed

func is_solved() -> bool:
	return (trashed and should_take) or ((correct_rip_line == -1 or cut == correct_rip_line) and len(correct_erased) == len(erased_words) and not erased_words.any(func(x): return not x in correct_erased))

func _split_up_text(txt: String) -> Array:
	return Array(txt.split("\n")).map(func(txt_line): return Array(txt_line.split(" ")).filter(func(x: String): return not x.is_empty()))

var random_note: Dictionary
var text: String
var text_lines: Array
var word_positions = []
var correct_erased = []
var correct_rip_line: int
var should_take: bool = false

func _ready() -> void:
	random_note = note_options.pick_random()
	correct_rip_line = random_note["rip_line_index"]
	correct_erased = random_note["erase"]
	should_take = random_note["take"]
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


var knife_mode = false
func enter_inspect_mode():
	super.enter_inspect_mode()
	
	if active_tool is Tool and active_tool.type == Tool.Type.KNIFE:
		knife_mode = true
		print("cutting")
	else:
		knife_mode = false
		if active_tool is Tool and active_tool.type == Tool.Type.TRASH_BAG:
			player.inspect_inventory.exit_inspect_mode()
			hide()
			G_node3d.disable_rigid_colliders(self)
			trashed = true

func exit_inspect_mode():
	super.exit_inspect_mode()
	line = cut
	_move_cut()

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
	#var word_length = len(words[text_word])
	var chars_before_word = 0
	for i in range(text_word):
		chars_before_word += len(words[i]) + 1
	return Vector3(chars_before_word * 0.0197, 0, text_line * 0.082)


func _move_crossout_to_word():
	if line >= cut: return
	# Reset position
	$Crossout.position = crossout_origin
	# Locally (accounting for rotation) move it to the word
	$Crossout.translate_object_local(_get_position_of_word(line, word))
	$Crossout/Image.scale = Vector3(len(text_lines[line][word]) * 0.375, 1, 1)

var recorded_erased := {}
func _confirm_crossout():
	for erased in erased_words:
		if erased[0] == line and erased[1] == word: return
	var copy = $Crossout.duplicate()
	$PreviouslyCrossedOut.add_child(copy)
	erased_words.append([line, word, text_lines[line][word]])
	if not line in recorded_erased:
		recorded_erased[line] = []
	recorded_erased[line].append(copy)
	print("used pen to crossout SFX")
	$CrossoutSound.play()


func _confirm_cut():
	if cut >= line:
		if cut != line:
			$CutSound.play()
			print("sliced SFX")
		cut = line

func _move_cut():
	if cut >= line:
		$MeshInstance3D2.mesh.material.set_shader_parameter("line", line)
		$MeshInstance3D2/Label3D.text = "\n".join(text.split("\n").slice(0, line))
		for i in recorded_erased.keys():
			if i > cut - 1 or i > line - 1:
				for crossed in recorded_erased[i]:
					crossed.hide()
			else:
				for crossed in recorded_erased[i]:
					crossed.show()
		


@onready var crossout_origin = $Crossout.position
func _unhandled_key_input(event: InputEvent):
	if not is_inspected: return
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
				if knife_mode:
					_confirm_cut()
				else:
					_confirm_crossout()
			_:
				return
		if knife_mode:
			_move_cut()
		else:
			_move_crossout_to_word()


func _handle_mouse_button(event):
	if not is_inspected: return
	if not event.pressed and event.button_index == 1:
		if knife_mode:
			_confirm_cut()
		else:
			_confirm_crossout()


func _input_event_collider(_camera: Camera3D, event: InputEvent, event_position: Vector3,
		_normal: Vector3, _shape_idx: int, _collision_object: CollisionObject3D) -> void:
	if not event is InputEventMouseMotion: return
	if not knife_mode:
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
	if knife_mode:
		if nearest == null:
			line = 100
		else:
			line = nearest[0] + 1
		_move_cut()
	else:
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
