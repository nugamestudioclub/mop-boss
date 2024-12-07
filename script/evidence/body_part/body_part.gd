extends Evidence

var is_in_trash = false

func is_altered() -> bool:
	return is_in_trash

func is_solved() -> bool:
	return is_in_trash

func enter_inspect_mode():
	super.enter_inspect_mode()
	if active_tool is Tool and active_tool.type == Tool.Type.TRASH_BAG:
		player.inspect_inventory.exit_inspect_mode()
		hide()
		G_node3d.disable_rigid_colliders(self)
		is_in_trash = true
