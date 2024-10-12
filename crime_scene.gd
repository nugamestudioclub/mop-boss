extends Node3D


func get_children_recursive(in_node: Node, array:=[]):
	array.push_back(in_node)
	for child in in_node.get_children():
		array = get_children_recursive(child, array)
	return array


func call_on_crime_scene(callable: Callable):
	for child in get_children_recursive(self):
		if child is NodeSpawner:
			callable.call(child)


func _ready():
	call_on_crime_scene(func(spawner): spawner.spawn())


func _input(event):
	if event is InputEventKey:
		if event.pressed: return
		elif event.keycode == KEY_R:
			#$"../InspectView".inspected_node = null
			call_on_crime_scene(func(spawner): spawner.despawn())
			call_on_crime_scene(func(spawner): spawner.spawn())
