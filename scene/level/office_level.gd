extends Node3D

func _input(event):
	if event is InputEventKey:
		if event.pressed: return
		elif event.keycode == KEY_R:
			end_level()

func start_level():
	$LevelGenerationManager.clear_level()
	$LevelGenerationManager.generate_level()

func end_level():
	get_tree().change_scene_to_file("res://scene/level/alley_level.tscn")
