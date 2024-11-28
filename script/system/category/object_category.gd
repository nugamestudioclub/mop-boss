class_name Category
extends Node


@export var weight: int = 1


func pick_node() -> PackedScene:
	var child = NodeHelper.random_child_weighted(self)
	if child == null or child.scene == null: return null
	return child.scene
