extends Node3D

# TODO: Fix this function because I hate you godot why not global scale?
"""Scales the inputed node (and any children) to fit within an area (bounds)"""
func scale_to_fit(node: Node3D, _bounds: float): #TODO: change bounds to vector3
	var furthest_end := Vector3.ZERO
	var furthest_start := Vector3.ZERO
	for mesh in node.get_children():
		if not mesh is VisualInstance3D: continue
		var aabb = mesh.get_aabb()
		aabb.position *= mesh.scale
		aabb.end *= mesh.scale
		if aabb.end.length() > furthest_end.length():
			furthest_end = aabb.end
		if aabb.position.length() > furthest_start.length():
			furthest_start = aabb.position
	var biggest_axis = AABB(furthest_start, furthest_end - furthest_start).get_longest_axis_size()
	#node.scale = node.scale.normalized() * bounds / biggest_axis
	print(biggest_axis)

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
	var transf = object.global_transform

	# Calculate the object's position relative to the rotation center
	var relative_position = transf.origin - world_position

	# Create a combined rotation basis using Euler angles
	var rotation_basis = Basis()
	rotation_basis = rotation_basis.rotated(Vector3(1, 0, 0), angles_radians.x) # Rotate around local X
	rotation_basis = rotation_basis.rotated(Vector3(0, 1, 0), angles_radians.y) # Rotate around local Y
	rotation_basis = rotation_basis.rotated(Vector3(0, 0, 1), angles_radians.z) # Rotate around local Z

	# Rotate both the relative position and the object's basis
	var rotated_position = rotation_basis * relative_position
	var rotated_basis = rotation_basis * transf.basis

	# Set the object's new global transform, updating both position and orientation
	transform.origin = world_position + rotated_position
	transform.basis = rotated_basis

	object.global_transform = transf

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
