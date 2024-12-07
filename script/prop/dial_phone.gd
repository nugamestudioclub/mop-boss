#class_name DialPhone
extends InspectableObject


# Player pressed a key
#func _unhandled_input(event: InputEvent):
	#if not event is InputEventKey: return
	#
	#if event.keycode == KEY_0:
		#var current_scene = get_tree().get_current_scene()
		#current_scene.end_level()

@onready var rotary = $Mesh/RotaryDial_low
@onready var rotary_default: Vector3 = rotary.rotation
@onready var plane_reference_1 = $Holes/CollisionShape3D
@onready var plane_reference_2 = $Holes/CollisionShape3D5
@onready var plane_reference_3 = $Holes/CollisionShape3D9
@onready var plane := Plane(plane_reference_1.position, plane_reference_2.position, plane_reference_3.position)

var moving_hole_index = -1
var elapsed: float = 0.0
var end = 0.0
var go_back = false

func _input_event_collider(
	camera: Camera3D,
	event: InputEvent,
	event_position: Vector3,
	normal: Vector3,
	shape_idx: int,
	collider: CollisionObject3D):
	
	if not is_inspected: return
	
	if event is InputEventMouseButton:
		if event.pressed: return
		# check rotaty isn't being moved right now
		# and user is left clicking
		if event.button_index == 1 and rotary.rotation == rotary_default:
			moving_hole_index = shape_idx
			elapsed = 0.0
			go_back = false
			end = (moving_hole_index * TAU/14) + TAU/10

func _process(delta: float):
	if not $Timer.is_stopped(): return
	if moving_hole_index != -1:
		if not go_back:
			var lerped = lerp(0.0, end, elapsed)
			if abs(lerped - end) > 0.05: # run this rotation thing until it gets very close to the end
				rotary.rotation = rotary_default
				rotary.rotate(plane.normal, lerped)
				elapsed += 2.5 * delta / end
			else:
				# move towards reset
				elapsed = 0
				$Timer.start()
		else:
			# opposite direction
			var lerped = lerp(end, 0.0, elapsed)
			if lerped > 0.05: # run this rotation thing until it gets very close to the start
				rotary.rotation = rotary_default
				rotary.rotate(plane.normal, lerped)
				elapsed += 4 * delta / end
			else:
				if rotary.rotation != rotary_default:
					# rotation is done
					if moving_hole_index == 0:
						get_tree().get_current_scene().end_level()
					rotary.rotation = rotary_default


func _on_timer_timeout():
				go_back = true

@onready var ring = $"../IntroSequence/PhoneRing"
@onready var level_manager = $".."

func enter_inspect_mode():
	if ring.playing:
		ring.stop()
		level_manager.on_line_finished()
	super.enter_inspect_mode()
