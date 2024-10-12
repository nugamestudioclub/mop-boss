class_name NodeSpawner
extends Node3D


@export var options: Array[PackedScene] = []
@export var object_types: Array[String] = []

var spawned_node: Node3D = null # intialize spawned_node, got it ready for despawn

# Called when the node enters the scene tree for the first time.
func _ready():
	$EditorMarker.hide() #$ abbreviates get_node(), this also gets descendants not just children; hide = invisible

func spawn():
	if options.is_empty(): return # Hazem here, this has no objects assigned to it so job done
	var random_scene: PackedScene = options.pick_random() # Pick random, built in for arrays
	var random = random_scene.instantiate() # Creates an instance of a root node yeah
	random.setup() # Defined in the donut and lock, assumes both will have a setup() function
	spawned_node = random # keeping track of the spawned node
	add_child(random) # adds the randomly selected object as a child of the spawner

func despawn():
	spawned_node.queue_free() # built-in, queues node to be deleted after next frame
	# hello chat
