extends Node3D

var stored_objects: Dictionary = {}

var max_objects: int = 3

func is_storable(object: Node):
	return (object is Tool and object.visible)

# Put the object into your inventory
func store_object(object: RigidBody3D):
	if not stored_objects.size() < max_objects: return null
	if object in stored_objects:
		print("WARNING: already stored object")
		return
	
	stored_objects[object] = {
	"parent": object.get_parent()
	}
	
	object.reparent(self)
	object.set_physics_process(false)
	object.visible = false
	
	print("stored:", object.name)

# Take out the object in your inventory
func retrieve_object(object: RigidBody3D):
	if not stored_objects.has(object): 
		print("WARNING: no such object") 
		return
	
	var parent = stored_objects[object]["parent"]
	if is_instance_valid(parent):
		object.reparent(parent)
	else:
		object.reparent(get_tree().current_scene)
	
	object.set_physics_process(true)
	object.visible = true
	
	stored_objects.erase(object)
	print("retrieved:", object.name)

# Retrieves an object from slots 1, 2, ...
func retrieve_slot_object(slot: int):
	if slot > stored_objects.size() or slot < 1: return null
	
	var object = stored_objects.keys()[slot - 1]
	retrieve_object(object)
	return object
