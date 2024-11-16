extends Node3D


# Assume this is called ON SPAWNED IN NODE SPAWNER
func _ready() -> void:
	var spawnItem = $Dumpster
	var spawnScript = spawnItem.get_script()
	
	# create dependencies (if it has any)
	if spawnScript.has_method("generate_dependencies"):
		spawnScript.generate_dependencies()
	
	# create independencies (if it has any)
	if spawnScript.has_method("generate_independencies"):
		spawnScript.generate_dependencies()
		
		
