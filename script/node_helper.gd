extends Node

@onready var inspector_canvas_layer_node := $"/root/World/InspectLayer"

func get_descendants(in_node: Node, array: Array[Node] = []) -> Array[Node]:
	#array.push_back(in_node)
	for child in in_node.get_children():
		array.push_back(child)
		array = get_descendants(child, array)
	return array

func destroy_children(children):
	for child in children:
		print("begone ", child)
		child.free()

func total_weight(node: Node):
	return node.get_children().filter(func(child): return child is Category).reduce(func(acc, child): return child.weight + acc, 0)


func random_child_weighted(node: Node) -> Node:
	var pick = randi_range(1, total_weight(node))
	var sum = 0
	var sorted_children = node.get_children().filter(func(child): return child is Category)
	sorted_children.sort_custom(func(child_a, child_b): return child_b.weight >= child_a.weight)
	for child in sorted_children:
		sum += child.weight
		if sum >= pick:
			return child
	return null
