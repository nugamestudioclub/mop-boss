extends Node3D

#@export var office_level: PackedScene
#@onready var world = self.get_parent()

func _input(event):
	if event is InputEventKey:
		if event.pressed: return
		elif event.keycode == KEY_R:
			start_level()

func start_level():
	$LevelGenerationManager.clear_level()
	$LevelGenerationManager.generate_level()

func end_level():
	get_tree().change_scene_to_file("res://scene/level/office_level.tscn")
	
	# send player back to the office
	#var current_scene = get_tree().get_current_scene()
	#var new_level = office_level.instantiate()
	#world.add_child(new_level)
	#self.queue_free()
	#current_scene.queue_free()
	# might need some way to pass information to office scene, like performance stats
