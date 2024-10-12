extends Node


@export var weight: int = 1


func pick_node() -> Node3D:
	var child = get_parent().random_child_weighted(self)
	if child == null: return null
	if child == null or child.scene == null: return null
	return child.scene.instantiate()
