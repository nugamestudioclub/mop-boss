# Dumpster.gd
extends StaticBody3D

# Reference to the connected parent and child node
var creator_reference = null
var spawned_lock = null

@onready var lock_spawner = $"../NodeSpawner"
@onready var door_left = $"../DoorLeft"
@onready var door_right = $"../DoorRight"

func _ready() -> void:
	# Connect signals
	creator_reference = false
	spawned_lock = lock_spawner.spawn_random()
	
	# Add self as parent to child if it needs it
	#if "dumpster" in creation_reference:
	#if NodeHelper.has_variable("dumpster", creation_reference):
	spawned_lock.dumpster = self
	print("hiiii",spawned_lock.dumpster)
	
	print(spawned_lock)
	#lock_spawner.spawn(null)
	#lock_spawner.spawn(dumpster)

## Send an event to the parent (dumpster won't be dependent so pass)
#func send_event_up(event: String) -> void:
	#pass
#
## Handle an event from the parent (dumpster won't be dependent so pass)
#func _on_event_up(event: String) -> void:
	#pass
#
## Send an event to the child
#func _send_event_down(event: String) -> void:
	#if creation_reference and creation_reference.has_method("on_parent_event"):
		#creation_reference.on_creator_event(event)
#
## Handle an event from the child
#func _on_event_down(event: String) -> void:
	#if event == "unlocked":
		#print("Dumpster received 'unlocked' event from the lock")
		#self.visible = false

# Unlock the Dumpster's doors
func unlock() -> void:
	print("Dumpster doors are now unlocked!")
	door_left.freeze = false
	door_left.add_to_group("holdable")
	door_right.freeze = false
	door_right.add_to_group("holdable")
