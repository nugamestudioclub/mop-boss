extends InspectableObject

@onready var alley_level = $"/root/AlleyLevel"
@onready var lock_codes = alley_level.get_node("Graffiti")
@onready var player_hand = alley_level.get_node("Player").hand


func _toggle_visibility(node: Node3D, is_shown: bool):
	if node != self: return
	$SpotLight3D.visible = is_shown
	$ColorDisk.visible = is_shown
	for code in lock_codes.get_children():
		code.visible = is_shown


func _enter_hold_on_node(node: Node3D): _toggle_visibility(node, true)
func _drop_hold_on_node(node: Node3D): _toggle_visibility(node, false)


func _ready():
	player_hand.enter_hold_on_node.connect(_enter_hold_on_node)
	player_hand.drop_hold_on_node.connect(_drop_hold_on_node)
