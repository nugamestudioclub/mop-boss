extends Node


@onready var node_spawners: Array[Node] = get_tree().get_nodes_in_group("node_spawner")

#var required_categories: Array # Array[Category]


func _spawner_has_category(node: Node, category_name: String) -> bool:
	return node.get_children().any(func(category):
		return (category.name == category_name
		or category.find_child(category_name) != null)
	)


func _count_categories(nodes: Array[Node]) -> Dictionary:
	var count := {}
	for node in nodes:
		for category in get_children():
			if _spawner_has_category(node, category.name):
				if not count.has(category):
					count[category] = 0
				count[category] += 1
	return count


func _ready() -> void:
	# find how many optoins each category has within the scene
	var required_category_option_count: Dictionary = _count_categories(node_spawners)
	# now we need to find the scenes with the least options to spawn first
	var pairs = required_category_option_count.keys().map(func (key): return [key, required_category_option_count[key]])
	print(pairs)
	pairs.sort_custom(func(pair1, pair2): return pair1[1] < pair2[1])
	# should be a sorted array of the categories from least options to most options (availability)
	var required_categories = pairs.map(func(pair): return pair[0])
	print(required_categories)
	_generate_level(required_categories)


func _generate_level(required_categories):
	for category in required_categories:
		node_spawners = get_tree().get_nodes_in_group("node_spawner")
		for spawner in node_spawners:
			if _spawner_has_category(spawner, category.name):
				if category is CategoryItem:
					spawner.spawn(category.scene)
					break
				elif category is Category:
					spawner.spawn(category.pick_node())
					break
	
	node_spawners = get_tree().get_nodes_in_group("node_spawner")
	print(node_spawners)
	for spawner in node_spawners:
		print("Here we are again ", spawner.get_children())
		spawner.spawn_random()
