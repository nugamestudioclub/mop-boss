# Lock.gd
extends Node

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

# Unlock logic
func _unlock() -> void:
	print("Lock is now unlocked!")
	if dumpster and dumpster.has_method("unlock"):
		dumpster.unlock()
	#send_event_up("unlocked")
