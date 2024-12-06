extends Node3D

# Hand customize
var hold_button = MOUSE_BUTTON_LEFT
var hold_group = "holdable"
var max_objects: int = 4

# Idk hand parameters
var held_objects: Dictionary = {}
var target = null
var highlighted = null

@onready var player: RigidBody3D = self.get_owner()
@onready var camera_player: Camera3D = $"../PlayerPov"

signal enter_hold_on_node(node: Node3D)
signal drop_hold_on_node(node: Node3D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _start_holding(object: RigidBody3D):	
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
	$PickupSound.play()

func _stop_holding(object: RigidBody3D):
	print("Exiting hold")
	var material = object.physics_material_override
	drop_hold_on_node.emit(object)
	
	object.linear_damp = held_objects[object]["linear_damp"]
	material.absorbent = held_objects[object]["physics_material"]
	
	held_objects.erase(object)

func stop_holding_all():
	var all_objects = held_objects.keys()
	for object in all_objects:
		_stop_holding(object)

func _throw(object):
	var object_mass = held_objects[object]["mass"]
	var throw_strength = object.global_position  - player.global_position
	
	object.apply_central_impulse(throw_strength * object_mass * 8)
	_stop_holding(object)

func throw_all():
	var all_objects = held_objects.keys()
	for object in all_objects:
		_throw(object)

func get_held_tool():
	var held_tool = null
	if held_objects.size() == 1:
		held_tool = held_objects.keys()[0]
	return held_tool

func _can_hold(object):
	return (object is RigidBody3D and 
	object.is_in_group(hold_group) and 
	object.visible)

func _input(event):
	if Input.is_action_just_pressed("hold"):
		print(target, _can_hold(target), held_objects.size())
		if _can_hold(target) and held_objects.size() < max_objects:
			_start_holding(target)
	elif Input.is_action_just_pressed("throw"):
		throw_all()
	elif Input.is_action_just_pressed("ui_cancel"):
		stop_holding_all()

func _largest_object_radius(held_objects):
	var max_radius = 0
	for object in held_objects:
		var object_radius = held_objects[object]["radius"]
		if object_radius > max_radius:
			max_radius = object_radius
	return max_radius

func _physics_process(delta):
	var exclude = [player]
	exclude.append_array(held_objects.keys())
	target = G_raycast.get_mouse_target(camera_player, exclude)
	
	if target != highlighted:
		if highlighted != null:
			G_highlight.remove_highlight(highlighted)
			highlighted = null
		if target != null and _can_hold(target):
			G_highlight.add_highlight(target)
			highlighted = target
	
	if held_objects != {}:
		#var origin_object = held_object.global_transform.origin
		var origin_hand = self.global_transform.origin
		
		# prevent the hand from phasing through walls
		var object_radius = _largest_object_radius(held_objects)
		var raycast_hand_result = G_raycast.raycast_mouse(camera_player, (2 + object_radius), exclude)
		
		if raycast_hand_result.has("position"):
			var barrier_intersect = raycast_hand_result.position
			var direction = (camera_player.global_position - barrier_intersect).normalized()
			
			origin_hand = barrier_intersect + (direction * object_radius)
			self.global_position = origin_hand
		else:
			self.position = Vector3(0, 0, -2) #broken with offset based on current calculations
			# probably fix by calculating from expected hand position; used to be (0.2, -0.4, -2)
		for object in held_objects:
			update_object(object, delta)

var orbit_time = 0.0  # A running timer for the orbit

#func _physics_process(delta):
	#orbit_time += delta  # Increment the timer with the frame's delta time
	#if held_objects != {}:
		#for object in held_objects:
			#update_object(object, delta)

func update_object(object, delta):
	var hand_origin = self.global_transform.origin
	var object_origin = object.global_transform.origin

	# Orbit parameters
	var orbit_radius = 0.0 + held_objects[object]["radius"]  # Adjust as needed
	var orbit_speed = 2.0  # Speed of orbit
	var orbit_index = held_objects.keys().find(object)  # Unique index for the object
	var angle = orbit_time * orbit_speed + orbit_index * 2 * PI / held_objects.size()
	var move_factor = 3
	
	# Calculate orbit position
	var orbit_offset = Vector3(
		orbit_radius * cos(angle),
		0.0,  # Adjust for vertical orbit by adding sin(angle) to Y
		orbit_radius * sin(angle)
	)
	var target_position = hand_origin + orbit_offset

	# Move object to orbit position
	var delta_position: Vector3 = (target_position - object_origin)
	object.set_linear_velocity(delta_position * 240 * delta * move_factor)
	
	#func update_object(object, delta):
		#var origin_object = object.global_transform.origin
		#var origin_hand = self.global_transform.origin
		#
		## prevent object from trying to phase through wall
		#var exclude = [player]
		#exclude.append_array(held_objects.keys())
		#var raycast_object_result = G_raycast.raycast_to(origin_object, origin_hand, exclude)
		#
		#var move_factor = 2
		#if raycast_object_result.has("position"):
			##print("GO TO PLAYER")
			#origin_hand = camera_player.global_transform.origin
		#
		#var delta_origin: Vector3 = (origin_hand - origin_object)
		#var squared_delta = delta_origin.length()
		#delta_origin *= squared_delta
		#
		#object.set_linear_velocity(delta_origin * 240 * delta * move_factor)
