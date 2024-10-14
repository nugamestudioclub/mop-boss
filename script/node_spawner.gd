class_name NodeSpawner
extends Node3D


var spawned_node: Node3D = null

func _ready():
	$EditorMarker.queue_free()

func spawn_random():
	#if self.get_child_count() > 0: await(NodeHelper.destroy_children(self.get_children())) #self.get_child(0).free() #NodeHelper.destroy_children(self.get_children())
	#var categories = self.get_children().filter(func(child): return child is Category)
	var random = NodeHelper.random_child_weighted(self)
	random = random.pick_node()
	if random == null: return
	spawn(random)
	

func spawn(scene: PackedScene):
	if spawned_node != null: return
	self.remove_from_group("node_spawner")
	spawned_node = scene.instantiate()
	if spawned_node.has_method("setup"): spawned_node.setup()
	add_child(spawned_node)


func despawn():
	if spawned_node == null: return
	spawned_node.free()
