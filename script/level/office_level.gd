extends Node3D

# Get data from last cleanup (if there was one)
var total_evidences = G_game_state.total_evidences
var cleaned_evidences = G_game_state.cleaned_evidences

const WIN_THRESHOLD = 0.8

var win_newspaper = preload("res://asset/image/news_win.png")
var lose_newspaper = preload("res://asset/image/news_lose.png")

@onready var fade_scene = $FadeScene


func _ready() -> void:
	start_level()

var intro_sequence_index = 0
# Start office level
func start_level():
	fade_scene.play("fade_in")
	# TODO: add game loading / intro screen with mop boss
	
	# if the player came back from a cleanup
	var checkPerformance: bool = (total_evidences != null)
	if not checkPerformance:
		intro_sequence_index = 0
	
	print(total_evidences)
	print(cleaned_evidences)
	# TODO: create a ring / call to phone
	call_player(checkPerformance)

# End office level
func end_level():
	fade_scene.play("fade_out")
	
	# Switch to scene at the START of the next frame (to avoid interupting other scripts)
	await get_tree().process_frame
	get_tree().change_scene_to_packed(G_game_state.alley_level)

# Send the player a phone call from the boss
func call_player(checkPerformance: bool):
	on_line_finished()
	
	if checkPerformance:
		var score = cleaned_evidences/total_evidences
		print("Cleaned up", score * 100, "percent of evidence")
		$Newspaper.show()
		var newspaper_image: Texture2D
		if score >= WIN_THRESHOLD:
			newspaper_image = win_newspaper
			print("win")
		else:
			newspaper_image = lose_newspaper
			print("lose")
		$Newspaper.get_node("Newspaper").mesh.material.albedo_texture = newspaper_image
		
		
		print("Voice lines based on performance")
	
	# New task voicelines
	print("Voice lines for new cleanup job")

func on_line_finished():
	var wait_time = 0.2
	if intro_sequence_index == 0: wait_time = 4
	elif intro_sequence_index == $IntroSequence.get_child_count(): return
	await get_tree().create_timer(wait_time).timeout
	$IntroSequence.get_child(intro_sequence_index).play()
	intro_sequence_index += 1
