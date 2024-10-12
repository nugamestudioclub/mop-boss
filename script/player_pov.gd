extends Camera3D


#const RAY_LENGTH = 1000

# Object the player is currently looking at
#var target = null
#
#"""Casts a raycast to see what the mouse is pointing at"""
#func raycast(ray_length=1000, exclude=[]):
	#var space_state = get_world_3d().direct_space_state
	#var mousepos = get_viewport().get_mouse_position()
#
	#var origin = project_ray_origin(mousepos)
	#var end = origin + project_ray_normal(mousepos) * ray_length
	#var query = PhysicsRayQueryParameters3D.create(origin, end)
	#query.exclude = exclude
	#query.collide_with_areas = true
#
	#var result = space_state.intersect_ray(query)
	#return result
	#
