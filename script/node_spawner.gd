class_name NodeSpawner
extends Node3D


var spawned_node: Node3D = null


func total_weight(node: Node):
	return node.get_children().reduce(func(acc, n): return n.weight + acc, 0)


func random_child_weighted(node: Node) -> Node:
	var pick = randi_range(1, total_weight(node))
	var sum = 0
	var sorted_children = node.get_children()
	sorted_children.sort_custom(func(child_a, child_b): return child_b.weight >= child_a.weight)
	for child in sorted_children:
		sum += child.weight
		if sum >= pick:
			return child
	return null


func _ready():
	$EditorMarker.free()


func spawn():
	if get_child_count() == 0: return
	var random = random_child_weighted(self)
	random = random.pick_node()
	if random == null: return
	if random.has_method("setup"): random.setup()
	spawned_node = random
	add_child(random)


func despawn():
	if spawned_node == null: return
	spawned_node.free()
