extends Area3D

@onready var player = $"../../Player"
@onready var smog_timer: Timer = Timer.new()  # Create a Timer dynamically
@onready var level_manager = $"../.."
@onready var world_environment = $"../Lighting/WorldEnvironment"
@onready var default_fog = world_environment.environment.fog_density

@onready var fog_timer: Timer = Timer.new()  # Reference to the Timer node

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)
	
	fog_timer.one_shot = false
	fog_timer.wait_time = 0.25
	fog_timer.connect("timeout", _on_fog_timer_timeout)
	add_child(fog_timer)

func _on_body_entered(body: Node):
	if body == player:
		print("player entered smog")
		player.head.start_cough()
		start_fog_increase()

func _on_body_exited(body: Node):
	if body == player:
		print("player exited smog")
		player.head.stop_cough()
		stop_fog_increase()

var target_fog_density = 0.10  # Desired final fog density
var fog_increase_step = 0.0025  # Amount to increase per step
var out_of_bounds: bool = false

func start_fog_increase():
	out_of_bounds = true
	fog_timer.stop()
	fog_timer.start()

func stop_fog_increase():
	if not fog_timer.is_inside_tree(): return
	out_of_bounds = false
	
	fog_timer.stop()
	fog_timer.start()

func _on_fog_timer_timeout():
	if out_of_bounds:
		var current_density = world_environment.environment.fog_density
		if current_density < target_fog_density:
			world_environment.environment.fog_density = min(current_density + fog_increase_step, target_fog_density)
		else:
			fog_timer.stop()
			level_manager.end_level()
	else:
		var current_density = world_environment.environment.fog_density
		if current_density > default_fog:
			world_environment.environment.fog_density = max(current_density - fog_increase_step, default_fog)
		else:
			fog_timer.stop()
