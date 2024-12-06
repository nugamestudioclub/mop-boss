extends Node3D

# Get data from last cleanup (if there was one)
var total_evidences = G_game_state.total_evidences
var cleaned_evidences = G_game_state.cleaned_evidences

const WIN_THRESHOLD = 0.8

var win_newspaper = preload("res://asset/image/news_win.png")
var lose_newspaper = preload("res://asset/image/news_lose.png")

func _ready() -> void:
	start_level()

var intro_sequence_index = 0
# Start office level
func start_level():
	G_game_state.fade_in_scene()
	
	# if the player came back from a cleanup
	var checkPerformance: bool = (total_evidences != null)
	if not checkPerformance:
		intro_sequence_index = 0
	
	print(total_evidences)
	print(cleaned_evidences)
	# TODO: create a ring / call to phone
	call_player(checkPerformance)

# End office level
func end_level():
	G_game_state.fade_out_scene()
	
	# Switch to scene at the START of the next frame (to avoid interupting other scripts)
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scene/level/alley_level.tscn")

# Send the player a phone call from the boss
func call_player(checkPerformance: bool):
	_start_call()
	
	if checkPerformance:
		var score = cleaned_evidences/total_evidences
		print("Cleaned up", score * 100, "percent of evidence")
		$Newspaper.show()
		var newspaper_image: Texture2D
		if score >= WIN_THRESHOLD:
			newspaper_image = win_newspaper
			print("win")
		else:
			newspaper_image = lose_newspaper
			print("lose")
		$Newspaper.get_node("Newspaper").mesh.material.albedo_texture = newspaper_image
		
		
		print("Voice lines based on performance")
	
	# New task voicelines
	print("Voice lines for new cleanup job")


# GRRR DOES NOT EMIT FINISHED() IF YOU DO STOP()
func _start_call():
	for audio in $IntroSequence.get_children():
		audio.play()
		await $IntroSequence.get_child(intro_sequence_index).finished
