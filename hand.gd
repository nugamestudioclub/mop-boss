extends Node3D

# Hand customize
var hold_button = MOUSE_BUTTON_LEFT
var hold_group = "holdable"

# Idk hand parameters
var hold_object: RigidBody3D = null
var object_radius = null

@onready var player: RigidBody3D = self.get_owner()
@onready var camera_player: Camera3D = $"../PlayerPov"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _enter_hold(object):
	hold_object = object
	var scale_object = hold_object.scale
	object_radius = 0.5 * max(scale_object.x, scale_object.y, scale_object.z)
	print("Entering hold")
	
	hold_object.freeze = false
	hold_object.linear_damp = 3
	var material = hold_object.physics_material_override
	material.absorbent = !material.absorbent
	return

func _cancel_hold(object):
	#hold_object.freeze = false
	
	print("Exiting hold")
	var material = hold_object.physics_material_override
	material.absorbent = !material.absorbent
	hold_object = null
	object_radius = null
	return

func _can_hold(object):
	return (object is RigidBody3D and 
	object.is_in_group(hold_group) and 
	object.visible)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed: return
		
		var target = Raycast.get_mouse_target(camera_player)
		
		if event.button_index == hold_button and player.can_move:
			if hold_object != null:
				_cancel_hold(hold_object)
			elif _can_hold(target):
				_enter_hold(target)
				
	elif Input.is_action_just_pressed("interact"):
		if hold_object != null:
			var throw_strength = hold_object.global_position  - player.global_position
			
			hold_object.apply_central_impulse(throw_strength)
			_cancel_hold(hold_object)


#func shapecast(origin, end, RAYLENGTH):
	#var boxShape3D = new BoxShape3D{
		#Size = new Vector3(2, 1, 3.5f)
	#}     
	#var physicsParams = new PhysicsShapeQueryParameters3D{
		#ShapeRid = boxShape3D.GetRid(),
		#Transform = Transform
	#}
	#var spaceState = GetWorld3D().DirectSpaceState;
	#var results = spaceState.IntersectShape(physicsParams)
	#if(results.Count > 0)
		#var collider = results[0]["collider"].AsGodotObject()
		#if(collider is StaticBody3D staticBody3D){
			#GD.Print(staticBody3D.Position)

func _physics_process(delta):
	if hold_object != null:
		var origin_object = hold_object.global_transform.origin
		var origin_hand = self.global_transform.origin
		
		var scale_object = hold_object.scale
		var object_radius = 0.5 * max(scale_object.x, scale_object.y, scale_object.z)
		
		# prevent the hand from phasing through walls
		var raycast_hand_result = Raycast.raycast_mouse(camera_player, (2 + object_radius), [player, hold_object])
		var ray_pos: Vector3 = origin_hand
		print(raycast_hand_result)
		if raycast_hand_result.has("position"):
			ray_pos = raycast_hand_result.position
			var barrier_intersect = raycast_hand_result.position
			
			#var direction = (camera_player.global_position - barrier_intersect).normalized()
			var direction = (camera_player.global_position - barrier_intersect).normalized()
			
			#origin_hand = ray_pos
			#var direction = (barrier_intersect - origin_hand).normalized()
			origin_hand = barrier_intersect + (direction * object_radius)
			self.global_position = origin_hand
			#self.position.x = 0
			#self.position.y = 0
		else:
			self.position = Vector3(0, 0, -2) #broken with offset based on current calculations
			# probably fix by calculating from expected hand position; used to be (0.2, -0.4, -2)
		
		# prevent object from trying to phase through wall
		
		var object_colliders = hold_object.get_contact_count()
		
		var raycast_object_result = Raycast.raycast_to(origin_object, origin_hand) #delta_origin + object_radius)
		#print(raycast_result)
		var move_factor = 1
		if raycast_object_result.has("position"): #and object_colliders > 0:
			print("GO TO PLAYER")
			origin_hand = camera_player.global_transform.origin
			
		#if object_colliders > 0:
			#var barrier_intersect = raycast_result.position
			#
			#var direction = (origin_object - barrier_intersect).normalized()
			#origin_hand = barrier_intersect + direction * object_radius
			
			#hold_object.set_linear_velocity(slide_direction * 240 * move_factor * delta)
			
		var delta_origin = (origin_hand - origin_object)
		hold_object.set_linear_velocity(delta_origin * 240 * delta * move_factor)
