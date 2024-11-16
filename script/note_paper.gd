extends Puzzle

var note_options: Array = preload("res://resource/puzzle/notes.json").data

func is_altered() -> bool:
	return false


func is_solved() -> bool:
	return false

var random_note: Dictionary
var text: String
func on_enter_level() -> void:
	random_note = note_options.pick_random()
	text = random_note.text
	$MeshInstance3D2/Label3D.text = text
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

func _on_puzzle_interact(_camera: Camera3D, event: InputEvent, event_position: Vector3,
		_normal: Vector3, shape_idx: int, collision_object: CollisionObject3D) -> void:
	#if not event is InputEventMouseButton: return
	#if event.pressed: return # check for button released
	print(event_position)
	var lines = text.split("\n")
	var y = round(event_position.y / 0.082) * 0.082
	var line = lines[floor(y/0.082) - 1]
	var words = line.split(" ")
	var chars = line.split("")
	var x = round(event_position.x / 0.002) * 0.002
	var char = floor(x/0.002)
	var word = 0
	var word_index = 0
	for w in words:
		word += len(w)
		if word >= char:
			break
		word += 1
		word_index += 1
	print("line ", line, "   word ", word_index)
	x = word * 0.002
	var z = event_position.z
	#print(event_position.rotated(Vector3.RIGHT, -rotation.x).rotated(Vector3.UP, -rotation.y).rotated(Vector3.FORWARD, -rotation.z))
	$Crossout.global_position = event_position#Vector3(word * 0.002, y, z)
	
	
	# TODO: erasing, ripping, and forging signatures
