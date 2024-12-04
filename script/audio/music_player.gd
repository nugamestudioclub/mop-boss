extends AudioStreamPlayer

var current_track: int = 0   # Index of the current track
var loop_start_index: int = 1  # The looping starts from "MB L1 Tense B1.wav"

@export var music_queue: Array[AudioStream]

func _ready() -> void:
	finished.connect(_on_track_finished)
	
	# Start by playing the first track
	play_track(current_track)

	# Check if the tracks were preloaded successfully (debugging)
	for track in music_queue:
		print("Preloaded track:", track.resource_path)

# Play a specific track by index
func play_track(track_index: int) -> void:
	if track_index >= 0 and track_index < music_queue.size():
		print("Playing track:", music_queue[track_index].resource_path)  # Debug print
		self.stream = music_queue[track_index]  # Set the current track
		self.play()  # Start playback
	else:
		print("Invalid track index:", track_index)

# Handle the transition when a track finishes
func _on_track_finished() -> void:
	print("Track finished, moving to next track...")

	current_track += 1  # Move to the next track

	# If we've reached the end of the queue, loop back to the first looping track
	if current_track >= music_queue.size():
		current_track = loop_start_index

	# Play the next track
	play_track(current_track)
