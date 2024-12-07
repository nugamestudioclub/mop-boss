extends Node3D

# Inspected memory
var target: Node3D = null
var highlighted_node: Node3D = null
var inspected_objects: Dictionary = {}

"""Moves object to inspect view saving previous state"""
func start_inspecting(object: RigidBody3D):
	# Save previous state
	_save_state(object)
	
	# Add object
	object.freeze = true
	object.global_position = Vector3.ZERO
	object.reparent(self)
	
	#G_highlight.remove_highlight(node)
	G_node3d.scale_to_fit(object, 1.3)  # 1.3 is a magic number so that all inspected objects are 1.3x some uniform size
	
	#if node is Evidence:
		#node.active_tool = player.hand.get_primary_held()
	
	# Tell object its inspected
	if object.has_method("enter_inspect_mode"):
		object.enter_inspect_mode()

"""Moves object from inspect window into previous state"""
func stop_inspecting(node: Node3D):
	# Load previous state
	_load_state(node)
	
	# Tell object its not inspected
	if node.has_method("exit_inspect_mode"):
		node.exit_inspect_mode()

"""Checks if an object is inspectable"""
func is_inspectable(object: Node):
	return (object is InspectableObject and object.visible)

func _save_state(object: Node):
	inspected_objects[object] = {
		"parent": object.get_parent(),
		"transform": object.transform,
		"freeze": object.freeze
	}

func _load_state(object: Node):
	var parent = inspected_objects[object]["parent"]
	if is_instance_valid(parent):
		object.reparent(parent)
	else:
		object.reparent(get_tree().current_scene)
	
	object.transform = inspected_objects[object]["transform"]
	object.freeze = inspected_objects[object]["freeze"]
	
	inspected_objects.erase(object)
