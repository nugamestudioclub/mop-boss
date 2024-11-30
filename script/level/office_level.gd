extends Node3D

# Get data from last cleanup (if there was one)
var total_evidences = G_game_state.total_evidences
var cleaned_evidences = G_game_state.cleaned_evidences

func _ready() -> void:
	start_level()

# Start office level
func start_level():
	G_game_state.fade_in_scene()
	
	# if the player came back from a cleanup
	var checkPerformance: bool = (total_evidences != null)
	
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
	if checkPerformance:
		print("Voice lines based on performance")
	
	# New task voicelines
	print("Voice lines for new cleanup job")
