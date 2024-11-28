extends Node3D

# Hand customize
var hold_button = MOUSE_BUTTON_LEFT
var hold_group = "holdable"

# Idk hand parameters
var hold_object: RigidBody3D = null
var object_radius = null
var object_mass = null

@onready var player: RigidBody3D = self.get_owner()
@onready var camera_player: Camera3D = $"../PlayerPov"
@onready var rotate_joint = $Generic6DOFJoint3D

signal enter_hold_on_node(node: Node3D)
signal drop_hold_on_node(node: Node3D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _start_hold(object):
	hold_object = object
	
	rotate_joint.set_node_b(hold_object.get_path())
	
	var scale_object = hold_object.scale
	object_radius = 0.5 * max(scale_object.x, scale_object.y, scale_object.z)
	object_mass = object.mass
	enter_hold_on_node.emit(object)
	print("Entering hold")
	
	hold_object.linear_damp = 3
	var material = hold_object.physics_material_override
	material.absorbent = !material.absorbent

func _stop_hold(object):
	print("Exiting hold")
	drop_hold_on_node.emit(object)
	rotate_joint.set_node_b(rotate_joint.get_path())
	
	var material = object.physics_material_override
	material.absorbent = !material.absorbent
	hold_object = null
	object_radius = null
	object_mass = null
	return

func _can_hold(object):
	return (object is RigidBody3D and 
	object.is_in_group(hold_group) and 
	object.visible)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed: return
		
		var target = G_raycast.get_mouse_target(camera_player)
		
		if event.button_index == hold_button and player.can_move:
			if hold_object != null:
				_stop_hold(hold_object)
			elif _can_hold(target):
				_start_hold(target)
				
	elif Input.is_action_just_pressed("interact"):
		if hold_object != null:
			var throw_strength = hold_object.global_position  - player.global_position
			
			hold_object.apply_central_impulse(throw_strength * object_mass * 8)
			_stop_hold(hold_object)

func _physics_process(delta):
	if hold_object != null:
		var origin_object = hold_object.global_transform.origin
		var rotation_object = hold_object.global_rotation
		var origin_hand = self.global_transform.origin
		var rotation_hand = self.global_rotation
		
		# prevent the hand from phasing through walls
		var raycast_hand_result = G_raycast.raycast_mouse(camera_player, (2 + object_radius), [player, hold_object])
		
		if raycast_hand_result.has("position"):
			var barrier_intersect = raycast_hand_result.position
			var direction = (camera_player.global_position - barrier_intersect).normalized()
			
			origin_hand = barrier_intersect + (direction * object_radius)
			self.global_position = origin_hand
		else:
			self.position = Vector3(0, 0, -2) #broken with offset based on current calculations
			# probably fix by calculating from expected hand position; used to be (0.2, -0.4, -2)
		
		# prevent object from trying to phase through wall
		
		var raycast_object_result = G_raycast.raycast_to(origin_object, origin_hand, [hold_object]) #delta_origin + object_radius
		#print(raycast_result)
		var move_factor = 2
		if raycast_object_result.has("position"): #and object_colliders > 0:
			#print("GO TO PLAYER")
			origin_hand = camera_player.global_transform.origin
		
		var delta_origin = (origin_hand - origin_object)
		
		hold_object.set_linear_velocity(delta_origin * 240 * delta * move_factor)
