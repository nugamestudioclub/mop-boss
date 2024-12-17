extends Camera3D

# Configuration variables
@export var max_trauma: float = 10.0
@export var trauma_reduction_rate := 1.0
@export var continuous_trauma_decay: float = 0.95

@export var max_x: float = 10.0
@export var max_y: float = 10.0
@export var max_z: float = 5.0

@export var noise: FastNoiseLite = null
@export var noise_speed := 50.0

# Trauma levels
var impulsive_trauma := 0.0
var constant_trauma := 0.0

var time := 0.0

@onready var default_rotation := Vector3.ZERO

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.set_seed(1)

func _process(delta):
	time += delta
	
	print("impulsive:", impulsive_trauma, " constant: ", constant_trauma)
	# decay impulsive trauma
	impulsive_trauma = max(impulsive_trauma - (delta * trauma_reduction_rate), 0.0)

	# overall trauma
	var total_trauma = impulsive_trauma + constant_trauma
	if total_trauma == 0.0: return

	# shake camera
	self.rotation_degrees.x = default_rotation.x + max_x * get_shake_intensity(total_trauma) * get_noise_from_seed(0)
	self.rotation_degrees.y = default_rotation.y + max_y * get_shake_intensity(total_trauma) * get_noise_from_seed(1)
	self.rotation_degrees.z = default_rotation.z + max_z * get_shake_intensity(total_trauma) * get_noise_from_seed(2)

func add_trauma_impulse(amount: float):
	impulsive_trauma = min(impulsive_trauma + amount, max_trauma)

func add_trauma_force(amount: float):
	constant_trauma = min(constant_trauma + amount, max_trauma)

func get_shake_intensity(total_trauma: float) -> float:
	return total_trauma * total_trauma

func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
