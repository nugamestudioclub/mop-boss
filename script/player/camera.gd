extends Camera3D

@export var max_trauma: float = 10.0
@export var min_trauma: float = 0.0

@export var trauma_reduction_rate := 1.0

@export var max_x: float = 10.0
@export var max_y: float = 10.0
@export var max_z: float = 5.0

@export var noise: FastNoiseLite = null
@export var noise_speed := 50.0

var trauma := 0.0

var time := 0.0

@onready var default_rotation := Vector3.ZERO

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.set_seed(1)

func _process(delta):
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	self.rotation_degrees.x = default_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	self.rotation_degrees.y = default_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
	self.rotation_degrees.z = default_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)
	
	print(default_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0))

func add_trauma(trauma_amount: float = 0.0):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func get_shake_intensity() -> float:
	# trauma squared if you will
	return trauma * trauma

func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
