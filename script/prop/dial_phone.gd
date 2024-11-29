class_name DialPhone
extends InspectableObject


# Player pressed a key
func _unhandled_input(event: InputEvent):
	if not event is InputEventKey: return
	
	if event.keycode == KEY_0:
		var current_scene = get_tree().get_current_scene()
		current_scene.end_level()

@onready var rotary = $Mesh/RotaryDial_low
@onready var rotary_default: Vector3 = rotary.rotation
@onready var plane_reference_1 = $Holes/CollisionShape3D
@onready var plane_reference_2 = $Holes/CollisionShape3D5
@onready var plane_reference_3 = $Holes/CollisionShape3D9
@onready var plane := Plane(plane_reference_1.position, plane_reference_2.position, plane_reference_3.position)

var moving_hole_index = -1
func _on_holes_input_event(_camera, event, event_position, normal, shape_idx):
	print(is_inspected)
	if not is_inspected: return
	if event is InputEventMouseButton:
		if event.button_index == 0:
			print("hi")
			if event.pressed:
				print(shape_idx)
				moving_hole_index = shape_idx
			else:
				moving_hole_index = -1
	elif event is InputEventMouseMotion:
		if moving_hole_index == -1: return
		rotary.rotation = rotary_default
		rotary.rotate(normal, event_position.angle_to(Vector3.ZERO))
