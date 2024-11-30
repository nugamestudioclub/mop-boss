# Dumpster.gd
extends StaticBody3D

# Reference to the connected parent and child node
var spawned_lock: Node = null

@onready var lock_spawner = $"../NodeSpawner"
@onready var door_left = $"../DoorLeft"
@onready var door_right = $"../DoorRight"

var door_script = preload("res://script/prop/dumpster_door.gd")

func _on_spawn_my_lock(node: Node3D):
	spawned_lock = node
	if "on_unlock" in spawned_lock:
		if not spawned_lock.on_unlock.is_connected(_unlock):
			spawned_lock.on_unlock.connect(_unlock)
	

func _ready() -> void:
	lock_spawner.on_spawn_node.connect(_on_spawn_my_lock)


# Unlock the Dumpster's doors
func _unlock() -> void:
	print("Dumpster doors are now unlocked!")
	door_left.freeze = false
	door_left.add_to_group("holdable")
	door_left.script = door_script
	door_right.freeze = false
	door_right.add_to_group("holdable")
	door_right.script = door_script
