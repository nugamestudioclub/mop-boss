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
	super._ready()
	chosen_variant = keylock_variants.pick_random()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(lock_definitions["colors"][chosen_variant["color"]])
	material.roughness = 0.3
	material.metallic = 0.6
	
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = material

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
	if (active_tool is Hammer and chosen_variant.get("special", "") == "use_hammer") or \
		(active_tool is PaperClip and chosen_variant.get("special", "") == "use_lock_pick"):
		_unlock()
		get_tree().current_scene.get_node("InspectLayer").exit_inspect_mode()
