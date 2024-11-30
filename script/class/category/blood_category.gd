class_name BloodCategory
extends Category

@export var surface: String

func pick_node() -> PackedScene:
	var child = get_node(surface)
	if child == null or child.scene == null: return null
	return child.scene
