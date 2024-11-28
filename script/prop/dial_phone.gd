extends RigidBody3D

var is_inspected = false

# Called when object starts being inspected
func _enter_inspect_mode():
	is_inspected = true

# Called when object stops being inspected
func _exit_inspect_mode():
	is_inspected = false

#
func _input(event: InputEvent) -> void:
	if is_inspected:
		print("yay")
