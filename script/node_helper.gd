extends Node

@onready var inspector_canvas_layer_node := $"/root/World/InspectLayer"

""" Gets children, children of children, etc """
func get_descendants(in_node: Node, array: Array[Node] = []) -> Array[Node]:
	#array.push_back(in_node)
	for child in in_node.get_children():
		array.push_back(child)
		array = get_descendants(child, array)
	return array

""" Destroys the children """
func destroy_children(children):
	for child in children:
		print("begone ", child)
		child.free()

""" Gets total weight of all children """
func total_weight(node: Node):
	return node.get_children().filter(func(child): return child is Category).reduce(func(acc, child): return child.weight + acc, 0)

""" Gets a random child based on all children weights """
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

""" Rotates an object around a coordinate point (on y axis)"""
func rotate_around_point(object: Node, world_position: Vector3, angle_degrees: float):
	# Convert the angle from degrees to radians
	var angle_radians = deg_to_rad(angle_degrees)
	
	# Calculate the object's current position relative to the rotation center
	var relative_position = object.global_transform.origin - world_position
	
	# Calculate the new rotated position using the rotation matrix for 3D
	var rotated_x = relative_position.x * cos(angle_radians) - relative_position.z * sin(angle_radians)
	var rotated_z = relative_position.x * sin(angle_radians) + relative_position.z * cos(angle_radians)
	
	# Update the position by applying the rotation, keeping the y position constant
	var new_position = Vector3(rotated_x, relative_position.y, rotated_z) + world_position
	object.global_transform.origin = new_position

#""" Rotates an object around a coordinate point (on y axis)"""
#func rotate_around_point(object: Node, world_position: Vector3, angle_degrees: float):
	## Convert the angle from degrees to radians
	#var angle_radians = deg_to_rad(angle_degrees)
		#
	## Get the object's global transform and calculate the local Y-axis
	#var global_transform = object.global_transform
	#var local_y_axis = global_transform.basis.y.normalized()
		#
	## Calculate the relative position from the world_position to the object
	#var relative_position = object.global_transform.origin - world_position
		#
	## Rotate the relative position around the local Y-axis
	#var rotated_position = relative_position.rotated(local_y_axis, angle_radians)
		#
	## Calculate the new position in world space
	#var new_position = rotated_position + world_position
	#object.global_transform.origin = new_position
