extends Node3D

# Hand customize
var hold_button = MOUSE_BUTTON_LEFT
var hold_group = "holdable"
var hold_strength = 2
var max_objects: int = 1

# Idk hand parameters
var held_objects: Dictionary = {}
var target = null
var highlighted = null

@onready var player: RigidBody3D = self.get_owner()

signal enter_hold_on_node(node: Node3D)
signal drop_hold_on_node(node: Node3D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start_holding(object: RigidBody3D):
	if not held_objects.size() < max_objects: return
	
	var scale_object = object.scale
	var radius = 0.5 * max(scale_object.x, scale_object.y, scale_object.z)
	var material = object.physics_material_override
	held_objects[object] = {
		"radius": radius,
		"mass": object.mass,
		"linear_damp": object.linear_damp,
		"physics_material": material.absorbent
	}
	enter_hold_on_node.emit(object)
	print("Entering hold")
	
	object.linear_damp = 3
	material.absorbent = false
	print(held_objects)
	$PickupSound.play()

func stop_holding(object: RigidBody3D):
	print("Exiting hold")
	var material = object.physics_material_override
	drop_hold_on_node.emit(object)
	
	object.linear_damp = held_objects[object]["linear_damp"]
	material.absorbent = held_objects[object]["physics_material"]
	
	held_objects.erase(object)

func stop_holding_all():
	var all_objects = held_objects.keys()
	for object in all_objects:
		stop_holding(object)

func _throw(object):
	var object_mass = held_objects[object]["mass"]
	var throw_strength = object.global_position  - player.global_position
	
	object.apply_central_impulse(throw_strength * object_mass * 8)
	stop_holding(object)

func throw_all():
	var all_objects = held_objects.keys()
	for object in all_objects:
		_throw(object)

func get_primary_held():
	var held_tool = null
	if held_objects.size() > 0:
		held_tool = held_objects.keys()[0]
	return held_tool

func can_hold(object):
	return (object is RigidBody3D and 
	object.is_in_group(hold_group) and 
	object.visible)

func _input(event):
	if player.inventory.is_open: return
	
	var primary_object = get_primary_held()
	
	if can_hold(target):
		if Input.is_action_just_released("hold"):
			print("OK YO")
			start_holding(target)
	else:
		print("wtf")
		if Input.is_action_just_released("drop"): 
			stop_holding_all()
		elif Input.is_action_just_released("throw"):
			throw_all()
	
	if Input.is_action_just_pressed("store") and primary_object is Tool:
		stop_holding(primary_object)
		player.inventory.tool.store_object(primary_object)
		$PickupSound.play()
	elif Input.is_action_just_pressed("slot_1"):
		var object = player.inventory.tool.retrieve_slot_object(1)
		if object != null:
			if primary_object != null:
				stop_holding(primary_object)
			start_holding(object)
	elif Input.is_action_just_pressed("slot_2"):
		var object = player.inventory.tool.retrieve_slot_object(2)
		if object != null:
			if primary_object != null:
				stop_holding(primary_object)
			start_holding(object)
	elif Input.is_action_just_pressed("slot_3"):
		var object = player.inventory.tool.retrieve_slot_object(3)
		if object != null:
			if primary_object != null:
				stop_holding(primary_object)
			start_holding(object)

func _largest_object_radius(held_objects):
	var max_radius = 0
	for object in held_objects:
		var object_radius = held_objects[object]["radius"]
		if object_radius > max_radius:
			max_radius = object_radius
	return max_radius

func _physics_process(delta):
	print(target)
	var exclude = [player]
	exclude.append_array(held_objects.keys())
	target = G_raycast.get_mouse_target(player.camera, exclude)
	
	if target != highlighted:
		if highlighted != null:
			G_highlight.remove_highlight(highlighted)
			highlighted = null
		if target != null and can_hold(target) and not player.inventory.is_open:
			G_highlight.add_highlight(target)
			highlighted = target
	
	if held_objects != {}:
		#var origin_object = held_object.global_transform.origin
		var origin_hand = self.global_transform.origin
		
		# prevent the hand from phasing through walls
		var object_radius = _largest_object_radius(held_objects)
		var raycast_hand_result = G_raycast.raycast_mouse(player.camera, (2 + object_radius), exclude)
		
		if raycast_hand_result.has("position"):
			var barrier_intersect = raycast_hand_result.position
			var direction = (player.camera.global_position - barrier_intersect).normalized()
			
			origin_hand = barrier_intersect + (direction * object_radius)
			self.global_position = origin_hand
		else:
			self.position = Vector3(0, 0, -2) #broken with offset based on current calculations
			# probably fix by calculating from expected hand position; used to be (0.2, -0.4, -2)
		for object in held_objects:
			update_object(object, delta)

var orbit_time = 0.0  # A running timer for the orbit

func update_object(object, delta):
	var hand_origin = self.global_transform.origin
	var object_origin = object.global_transform.origin

	# Orbit parameters
	var orbit_radius = 0.0 + held_objects[object]["radius"]  # Adjust as needed
	var orbit_speed = 2.0  # Speed of orbit
	var orbit_index = held_objects.keys().find(object)  # Unique index for the object
	var angle = orbit_time * orbit_speed + orbit_index * 2 * PI / held_objects.size()
	
	# Calculate orbit position
	var orbit_offset = Vector3(
		orbit_radius * cos(angle),
		0.0,  # Adjust for vertical orbit by adding sin(angle) to Y
		orbit_radius * sin(angle)
	)
	var target_position = hand_origin + orbit_offset

	# Move object to orbit position
	var delta_position: Vector3 = (target_position - object_origin)
	object.set_linear_velocity(delta_position * 240 * delta * hold_strength)
	
	# EXPERIMENTAL: trying to point object forward
	if Input.is_action_pressed("aim"):
		# Player's camera forward direction (camera looks along -Z)
		var direction = -player.camera.global_transform.basis.z

		# Object's current forward direction (assuming forward is -Z)
		var current_forward = -object.global_transform.basis.z

		# Compute rotation axis
		var rot_axis = current_forward.cross(direction)
		var axis_length = rot_axis.length()

		# Only proceed if we have a meaningful axis
		if axis_length > 0.0001:
			rot_axis = rot_axis.normalized()

			# Compute angle difference
			var dot = clamp(current_forward.dot(direction), -1.0, 1.0)
			var angle_diff = acos(dot)

			# Add a threshold to prevent jitter when nearly aligned
			var angle_threshold = 0.01
			if angle_diff > angle_threshold:
				var rotation_strength = 0.25 # adjust as needed
				var torque = rot_axis * angle_diff * rotation_strength
				object.apply_torque(torque)
