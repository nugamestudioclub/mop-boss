extends Node

@onready var inspector_canvas_layer_node := $"/root/World/InspectView"

func get_children_recursive(in_node: Node, array: Array[Node] = []) -> Array[Node]:
	array.push_back(in_node)
	for child in in_node.get_children():
		array = get_children_recursive(child, array)
	return array
