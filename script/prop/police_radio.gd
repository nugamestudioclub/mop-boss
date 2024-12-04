extends Evidence

@onready var knob1 = $Knob1
@onready var knob2 = $Knob2

const KNOB1_TICKS := 30
const KNOB1_RADS_PER_TURN = TAU/KNOB1_TICKS

const KNOB2_MIN_TICKS := 0
const KNOB2_MAX_TICKS := 5
const KNOB2_RADS_PER_TURN = PI/KNOB2_MAX_TICKS
var KNOB2_TICKS = 0

@onready var level_manager = $"../.."

func is_in_range(value, min_value, max_value) -> bool:
	return value >= min_value and value <= max_value

func is_altered() -> bool:
	return false

func is_solved() -> bool:
	return false

func on_enter_level() -> void:
	pass

func get_input_axis(posAction: String, negAction):
	var direction = 0
	if Input.is_action_just_released(posAction):
		direction = -1
	elif Input.is_action_just_released(negAction):
		direction = 1
	return direction

func _input_event_collider(_camera: Camera3D, _event: InputEvent, _event_position: Vector3,
	_normal: Vector3, _shape_idx: int, collision_object: CollisionObject3D) -> void:
	
	# Spin the dial based on input type
	var spin_direction = get_input_axis("rotate_view_down", "rotate_view_up")
	var knob_delta = spin_direction
	
	# Rotate dial based on collision object
	if collision_object == knob1:
		knob_delta *= KNOB1_RADS_PER_TURN
	elif collision_object == knob2:
		knob_delta *= KNOB2_RADS_PER_TURN
		
		if is_in_range(KNOB2_TICKS - spin_direction, KNOB2_MIN_TICKS, KNOB2_MAX_TICKS):
			KNOB2_TICKS -= spin_direction
		else:
			knob_delta = 0
	
	collision_object.rotate_y(knob_delta)


var LEVEL_MAX_TIME = 110
var LEVEL_MIN_TIME = 90

var EVENT_MAX_TIME_BETWEEN = 40
var EVENT_MIN_TIME_BETWEEN = 20

var EVENT_TYPES = {
	"roadblock_2mins": [preload("res://mbvoice add2min.wav"), 120], 
	"carcrash_1min": [preload("res://mbvoice carcrash.wav"), 60], 
	"detour_30second": [preload("res://mbvoice detour.wav"), 30],
	"train_5mins": [preload("res://mbvoice train.wav"), 300]
}
var EVENT_TIMELINE = []
var EVENT_TIMINGS = []
var LEVEL_TIME = 90
var EVENT_MAX = 6
var EVENT_MIN = 4

func _generate_radio_events() -> void:
	var event_total = randi_range(EVENT_MIN, EVENT_MAX)
	EVENT_TIMELINE = []
	
	for i in range(event_total):
		var new_event = EVENT_TYPES.keys().pick_random()
		EVENT_TIMELINE.append(new_event)
		var event_time_between = EVENT_TYPES[new_event][1]
		EVENT_TIMINGS.append(event_time_between)
		LEVEL_TIME += event_time_between

var voice_play_next
func _play_next_event():
	if EVENT_TIMELINE == []:
		print("no more events")
		return null
	
	var current_event = EVENT_TIMELINE[0]
	
	print("play the chatter over radio")
	print("something something about time left")
	
	voice_play_next = EVENT_TYPES[current_event][0]
	$StaticSound.play()
	
	EVENT_TIMELINE.remove_at(0)
	if EVENT_TIMELINE.is_empty():
		$SirenClose.play()
	return true

func wait(seconds) -> void:
	print(seconds)
	await get_tree().create_timer(seconds).timeout

func _ready() -> void:
	_generate_radio_events()
	
	var explain_events = "the police will: "
	for event in EVENT_TIMELINE:
		explain_events += (event + " and... ")
	print(explain_events)
	
	while true:
		if EVENT_TIMELINE == []:
			break
		
		var event_time_between = EVENT_TIMINGS[0]
		EVENT_TIMINGS.remove_at(0)
		await wait(event_time_between)
		
		
		var event_played = _play_next_event()
		print(EVENT_TIMELINE)
		
		if event_played == null:
			level_manager.end_level()
			break


func _on_static_sound_finished():
	$PoliceVoice.stream = voice_play_next
	$PoliceVoice.play()
