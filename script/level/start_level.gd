extends Node3D

func _input(event):
	if event is InputEventKey:
		if event.pressed: return
		elif event.keycode == KEY_R:
			start_level()

func _ready() -> void:
	start_level()

func start_level():
	$LevelGenerationManager.clear_level()
	$LevelGenerationManager.generate_level()

func end_level():
	# TODO: pass information to office scene, like performance stats (so boss can call and say hey)
	var total_evidences = 12
	var cleaned_evidences = 9
	
	G_game_state.total_evidences = total_evidences
	G_game_state.cleaned_evidences = cleaned_evidences
	print(G_game_state.total_evidences)
	
	get_tree().change_scene_to_file("res://scene/level/office_level.tscn")
