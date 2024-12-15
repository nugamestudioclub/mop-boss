extends Node3D

@onready var level_generation_manager = $System/LevelGenerationManager

# FOR DEBUGGING PURPOSES
#func _input(event):
	#if event is InputEventKey:
		#if event.pressed: return
		#elif event.keycode == KEY_R:
			#start_level()

func _ready() -> void:
	start_level()

func start_level():
	G_game_state.fade_in_scene()
	level_generation_manager.clear_level()
	level_generation_manager.generate_level()

func end_level():
	# TODO: pass information to office scene, like performance stats (so boss can call and say hey)
	var total_evidences = 12
	var cleaned_evidences = 9
	
	G_game_state.total_evidences = total_evidences
	G_game_state.cleaned_evidences = cleaned_evidences
	G_game_state.fade_out_scene()
	
	# Switch to scene at the START of the next frame (to avoid interupting other scripts)
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scene/level/office_level.tscn")
