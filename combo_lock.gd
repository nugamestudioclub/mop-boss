extends Node3D


# Called when the node enters the scene tree for the first time.
func setup():
	for child in $MeshInstances.get_children():
		var material = StandardMaterial3D.new()
		material.albedo_color = Color("ff6a00")
		material.roughness = 0.3
		material.metallic = 0.6
		child.get_child(0).material_override = material
