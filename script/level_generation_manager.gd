extends Node

const empty_tag = "empty_spawner"
const full_tag = "full_spawner"

#@onready var empty_spawners: Array[Node] = get_tree().get_nodes_in_group(empty_tag)

var required_categories: Array # Array[Category]


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

func all_group(group_name):
	return get_tree().get_nodes_in_group(group_name)

func _ready() -> void:
	# find how many optoins each category has within the scene
	var empty_spawners = all_group(empty_tag)
	
	var required_category_option_count: Dictionary = _count_categories(empty_spawners)
	# now we need to find the scenes with the least options to spawn first
	var pairs = required_category_option_count.keys().map(func (key): return [key, required_category_option_count[key]])
	pairs.sort_custom(func(pair1, pair2): return pair1[1] < pair2[1])
	# should be a sorted array of the categories from least options to most options (availability)
	required_categories = pairs.map(func(pair): return pair[0])
	generate_level()

func delete_level():
	for spawner in all_group(full_tag):
		spawner.despawn()

func generate_level():
	for category in required_categories:
		for spawner in all_group(empty_tag):
			if _spawner_has_category(spawner, category.name):
				if category is CategoryItem:
					spawner.spawn(category.scene)
					break
				elif category is Category:
					spawner.spawn(category.pick_node())
					break
	
	for spawner in all_group(empty_tag):
		spawner.spawn_random()
