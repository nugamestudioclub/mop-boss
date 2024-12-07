# Lock.gd
extends Evidence

# Reference to the connected parent and child node
var dumpster = null

## Send an event to the parent
#func send_event_up(event: String) -> void:
	#if creator_reference and creator_reference.has_method("on_child_event"):
		#creator_reference.on_child_event(event)
#
## Handle an event from the parent
#func on_event_up(event: String) -> void:
	#if event == "connect parent":
		#print("connect the parent")

signal on_unlock()

var keylock_variants: Array = G_lock.get_lock_variants("key_lock")
var chosen_variant: Dictionary
var lock_definitions: Dictionary = preload("res://asset/json/evidence/locks.json").data["definitions"]

func _ready() -> void:
	chosen_variant = keylock_variants.pick_random()
	var color = chosen_variant["color"]
	G_lock.create_specific_pattern_of_color(color, self)

var open = false
func is_solved() -> bool:
	return open

func is_altered() -> bool:
	return open

# Unlock logic
func _unlock() -> void:
	print("Lock is now unlocked!")
	$AnchorPoint.queue_free()
	$Rod.rotate_y(PI)
	on_unlock.emit()
	open = true


func enter_inspect_mode():
	super.enter_inspect_mode()
	if not active_tool is Tool: return
	var can_lock_pick = active_tool.type == Tool.Type.PAPER_CLIP and chosen_variant.get("special", "") == "use_lock_pick"
	var can_hammer = (active_tool.type == Tool.Type.HAMMER and chosen_variant.get("special", "") == "use_hammer")
	if can_hammer or can_lock_pick:
		_unlock()
		player.inspect_inventory.exit_inspect_mode()
