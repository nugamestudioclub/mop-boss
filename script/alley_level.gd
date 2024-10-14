extends Node3D


func call_on_crime_scene(callable: Callable):
	pass
	#for child in NodeHelper.get_children_recursive(self):
		#if is_instance_valid(child) and child is NodeSpawner:
			#callable.call(child)


func _ready():
	call_on_crime_scene(func(spawner): spawner.spawn_random())


func _input(event):
	if event is InputEventKey:
		if event.pressed: return
		elif event.keycode == KEY_R:
			#$"../InspectView".inspected_node = null
			call_on_crime_scene(func(spawner): spawner.despawn())
			call_on_crime_scene(func(spawner): spawner.spawn_random())
