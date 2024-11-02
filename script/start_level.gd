extends Node3D


func _input(event):
	if event is InputEventKey:
		if event.pressed: return
		elif event.keycode == KEY_R:
			$LevelGenerationManager.clear_level()
			$LevelGenerationManager.generate_level()
