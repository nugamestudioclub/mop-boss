extends Node3D

# Get data from last cleanup (if there was one)
var total_evidences = G_game_state.total_evidences
var cleaned_evidences = G_game_state.cleaned_evidences

func _ready() -> void:
	start_level()

# Start office level
func start_level():
	# if the player came back from a cleanup
	if total_evidences != null:
		print(total_evidences)
		print(cleaned_evidences)
	# TODO: create a ring / call to phone

# End office level
func end_level():
	get_tree().change_scene_to_file("res://scene/level/alley_level.tscn")
