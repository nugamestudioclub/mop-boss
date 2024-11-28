extends Node

# IMPORTANT PARAMETERS
var outline_shader: ShaderMaterial = preload("res://asset/shader/outline_material.tres")

"""Sets the outline around an object based on size"""
func resize_outline(node: Node3D, size: float):
	var outlined := []
	outlined.append_array(node.get_children())
	for child in outlined:
		outlined.append_array(child.get_children())
	for other_node in outlined:
		var shader_copy = outline_shader.duplicate()
		if other_node is CSGShape3D:
			other_node.material.next_pass = shader_copy
			other_node.material.next_pass.set_shader_parameter("size", size)
		elif other_node is MeshInstance3D:
			other_node.material_overlay = shader_copy
			other_node.material_overlay.set_shader_parameter("size", size)

"""Removes the highlight of an object"""
func remove_highlight(node: Node3D): 
	resize_outline(node, 0)

"""Adds a highlight to an object"""
func add_highlight(node: Node3D): 
	resize_outline(node, 1.05)
