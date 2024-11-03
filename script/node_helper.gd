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
#func rotate_around_local_x(object: Node, world_position: Vector3, angle_degrees: float):
	## Convert the angle from degrees to radians
	#var angle_radians = deg_to_rad(angle_degrees)
#
	## Get the object's current global transform
	#var transform = object.global_transform
#
	## Calculate the object's current position relative to the rotation center
	#var relative_position = transform.origin - world_position
#
	## Define a rotation basis around the object's local X-axis
	#var local_x_axis = transform.basis.x.normalized()
	#var rotation_basis = Basis(local_x_axis, angle_radians)
#
	## Rotate the relative position around the local X-axis
	#var rotated_position = rotation_basis * relative_position
#
	## Calculate the new global position by adding the rotated position to the world_position
	#transform.origin = world_position + rotated_position
#
	## Update the object's global transform
	#object.global_transform = transform

""" Rotates an object around a coordinate point using Vector3 rotations """
func rotate_around_point(object: Node, world_position: Vector3, angles_degrees: Vector3):
	# Convert angles to radians for rotation
	var angles_radians = Vector3(
		deg_to_rad(angles_degrees.x),
		deg_to_rad(angles_degrees.y),
		deg_to_rad(angles_degrees.z)
	)

	# Get the object's current global transform
	var transform = object.global_transform

	# Calculate the object's position relative to the rotation center
	var relative_position = transform.origin - world_position

	# Create a combined rotation basis using Euler angles
	var rotation_basis = Basis()
	rotation_basis = rotation_basis.rotated(Vector3(1, 0, 0), angles_radians.x) # Rotate around local X
	rotation_basis = rotation_basis.rotated(Vector3(0, 1, 0), angles_radians.y) # Rotate around local Y
	rotation_basis = rotation_basis.rotated(Vector3(0, 0, 1), angles_radians.z) # Rotate around local Z

	# Rotate both the relative position and the object's basis
	var rotated_position = rotation_basis * relative_position
	var rotated_basis = rotation_basis * transform.basis

	# Set the object's new global transform, updating both position and orientation
	transform.origin = world_position + rotated_position
	transform.basis = rotated_basis

	object.global_transform = transform


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
