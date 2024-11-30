extends Evidence

# Blood can count as a body part right?

var blood_options: Dictionary = preload("res://asset/json/evidence/blood.json").data
var blood_type: String
var applied_chemicals := []
var correct_chemicals := []
@export var surface: String

var blood_images := {
	"A": preload("res://asset/image/blood_a.png"),
	"B": preload("res://asset/image/blood_b.png"),
	"C": preload("res://asset/image/blood_c.png")
}

func is_altered() -> bool:
	return not applied_chemicals.is_empty()

func is_solved() -> bool:
	# solved if the blood was hidden
	return not visible

func _ready() -> void:
	randomize()
	blood_type = blood_options["blood_type"].keys().pick_random()
	$MeshInstance3D2.mesh.material.albedo_texture = blood_images[blood_type]
	var correct_chemical_letters: String = blood_options["blood_type"][blood_type][surface]
	for letter in correct_chemical_letters.split():
		# Find chemical using the letter and append it to the list of the correct order
		correct_chemicals.append(ChemicalBottle.Chemical.get(blood_options["chemicals"][letter]))


func enter_inspect_mode():
	super.enter_inspect_mode()
	get_tree().current_scene.get_node("InspectLayer").exit_inspect_mode()
	if active_tool is ChemicalBottle:
		var chemical = active_tool.contents
		applied_chemicals.append(chemical)
		print("used ", chemical, " to clean up blood type ", blood_type, " on surface ", surface)
		# take the last n chemicals
		var last_n_chemicals_used = applied_chemicals.slice(applied_chemicals.size() - len(correct_chemicals))
		print(last_n_chemicals_used)
		print("correct: ", correct_chemicals)
		if last_n_chemicals_used == correct_chemicals:
			print("clean!!")
			hide()
