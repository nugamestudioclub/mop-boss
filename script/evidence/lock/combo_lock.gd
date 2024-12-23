extends Evidence

var unlocked = false
var dumpster = null

var combolock_variants = {
	5: G_lock.get_lock_variants("combo_lock_5_digits"),
	4: G_lock.get_lock_variants("combo_lock_4_digits"),
	3: G_lock.get_lock_variants("combo_lock_3_digits")
}
var chosen_variant: Dictionary
var lock_definitions: Dictionary = preload("res://asset/json/evidence/locks.json").data["definitions"]

#@onready var combo_rod = $LockPivot/combo_rod
@onready var collision_rod = $collision_rod
@onready var pivot = $UnlockPivot

#
@onready var anchor_point = $AnchorPoint
@onready var pin_joint = $PinJoint3D

const FACES: int = 16
const RADS_PER_TURN := TAU/FACES

var correct_combo = [0, 0, 0, 0, 0]
var current_combo = [0, 0, 0, 0, 0]


signal on_unlock()

func is_altered() -> bool:
	var should_leave_alone = chosen_variant.get("special", "") == "leave_alone"
	var has_combo_been_modified = current_combo.any(func(x): return x != 0)
	return unlocked or (should_leave_alone and has_combo_been_modified)

func is_solved() -> bool:
	return current_combo == correct_combo

func _ready() -> void:
	randomize()
	var dial_count = randi_range(3, 5)
	print("i have a dial count of ", dial_count)
	chosen_variant = combolock_variants[dial_count].pick_random()
	var color = chosen_variant["color"]
	G_lock.create_specific_pattern_of_color(color, self)
	
	# BAD TEMPORARY FIX
	anchor_point.reparent(self.get_parent())
	pin_joint.node_a = self.get_path()
	pin_joint.node_b = anchor_point.get_path()
	
	# get rid of extra dials
	for i in range($Dials.get_child_count()):
		if i >= dial_count:
			$Dials.get_child(i).queue_free()
	correct_combo = G_lock.randomize_combo(chosen_variant, dial_count, FACES)
	current_combo = correct_combo.map(func(_x): return 0)
	print(correct_combo)
	print(current_combo)

func enter_inspect_mode():
	super.enter_inspect_mode()
	pin_joint.node_a = anchor_point.get_path()
	
	print("SO TRUE")
	if active_tool is Tool and active_tool.type == Tool.Type.HAMMER and chosen_variant.get("special", "") == "use_hammer":
		current_combo = correct_combo
		player.inspect_inventory.exit_inspect_mode()

func exit_inspect_mode():
	super.exit_inspect_mode()
	pin_joint.node_a = self.get_path()

func _input_event_collider(_camera: Camera3D, _event: InputEvent, _event_position: Vector3,
	_normal: Vector3, shape_idx: int, collision_object: CollisionObject3D) -> void:

	# Spin the dial based on input type
	var dial_delta = RADS_PER_TURN
	var spin_direction = G_lock.get_input_axis("spin_down", "spin_up")
	dial_delta *= spin_direction

	# Spin the dial if there is one
	if collision_object == $Dials:
		$Dials.get_child(shape_idx).rotate_z(dial_delta)
	
		current_combo[shape_idx] = G_lock.update_combo(current_combo, shape_idx, spin_direction, FACES)
	
	# Unlock if not already
	if not unlocked and is_solved():
		unlocked = true
		
		#combo_rod.rotate_y(PI)
		var rotate_vector = Vector3(0, 180, 0)
		G_node3d.rotate_around_point(collision_rod, pivot.global_position, rotate_vector)
		collision_rod.position += Vector3(0, 0.1, 0)
		anchor_point.queue_free()
		on_unlock.emit()
