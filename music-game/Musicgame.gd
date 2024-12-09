extends Node2D

@export var sound_sequence : Array[int] = []  # Store indices (0, 1, 2, 3)
@export var sounds : Array = ["button 1.mp3", "button 2.mp3", "button 3.mp3", "button 4.mp3"]
var sequence_position : int = 0
var is_playing_sequence : bool = false  # Prevent clicking during sequence
var score : int = 0  # Initialize score

#buttons
@onready var button1 : TextureButton = $'Button 1'
@onready var button2 : TextureButton = $'Button 2'
@onready var button3 : TextureButton = $'Button 3'
@onready var button4 : TextureButton = $'Button 4'

@export var pressed_texture : Texture  

# Normal textures for each button
@onready var normal_texture1 : Texture = button1.texture_normal
@onready var normal_texture2 : Texture = button2.texture_normal
@onready var normal_texture3 : Texture = button3.texture_normal
@onready var normal_texture4 : Texture = button4.texture_normal

# Label node to display score
@onready var score_label : Label = $'ScoreLabel'

# Feedback Label for showing correct/wrong messages
@onready var feedback_label : Label = $'FeedbackLabel'

# Preload AudioStreamPlayer nodes for each button
@onready var audio_player1 : AudioStreamPlayer2D = $'AudioPlayer1'
@onready var audio_player2 : AudioStreamPlayer2D = $'AudioPlayer2'
@onready var audio_player3 : AudioStreamPlayer2D = $'AudioPlayer3'
@onready var audio_player4 : AudioStreamPlayer2D = $'AudioPlayer4'

# Label node for "Next Round" message
@onready var next_round_label : Label = $'NextRoundLabel'

func _ready():
	# Connect button signals with the index using bind() instead of directly passing an array
	button1.connect("pressed", Callable(self, "_on_button_pressed").bind(0))
	button2.connect("pressed", Callable(self, "_on_button_pressed").bind(1))
	button3.connect("pressed", Callable(self, "_on_button_pressed").bind(2))
	button4.connect("pressed", Callable(self, "_on_button_pressed").bind(3))

	# Add a delay before the game starts
	await get_tree().create_timer(1.5).timeout 

	# Generate the first sequence
	generate_sequence(3)  # Starting with a sequence of 3 sounds
	play_sequence()

	# Update the score display
	update_score_label()

	# Initially hide the feedback and next round labels
	feedback_label.visible = false
	next_round_label.visible = false

# Generate a random sequence
func generate_sequence(length : int) -> void:
	sound_sequence.clear()
	for i in range(length):
		sound_sequence.append(randi() % sounds.size())  # Store it

# play the sequence for the player
func play_sequence() -> void:
	sequence_position = 0
	is_playing_sequence = true
	for index in sound_sequence:
		var audio_player : AudioStreamPlayer2D = get_audio_player_for_button(index)
		audio_player.play()

		# Add visual feedback
		var button : TextureButton = get_node("Button " + str(index + 1)) as TextureButton
		flash_button(button)

		# Wait for each sound to play
		await get_tree().create_timer(1.0).timeout  # Assuming each sound takes 1 second

	is_playing_sequence = false  # Allow user to interact after the sequence is played

# Get the appropriate AudioStreamPlayer for the button
func get_audio_player_for_button(button_index: int) -> AudioStreamPlayer2D:
	match button_index:
		0:
			audio_player1.stream = load("res://sounds/" + sounds[button_index]) as AudioStream
			return audio_player1
		1:
			audio_player2.stream = load("res://sounds/" + sounds[button_index]) as AudioStream
			return audio_player2
		2:
			audio_player3.stream = load("res://sounds/" + sounds[button_index]) as AudioStream
			return audio_player3
		3:
			audio_player4.stream = load("res://sounds/" + sounds[button_index]) as AudioStream
			return audio_player4
		_:
			# if invalid index
			print("Invalid button index: ", button_index)
			return audio_player1  # default fallback

# Flash button when sound 
func flash_button(button : TextureButton) -> void:
	var original_texture = button.texture_normal
	var original_pressed_texture = button.texture_pressed

	# Change the button color to flash it a color
	button.modulate = Color(1, 0, 0)  # Change to color

	# Wait for a short time before returning to the original texture
	await get_tree().create_timer(0.2).timeout
	
	# Reset the button color back to normal
	button.modulate = Color(1, 1, 1)  # Reset to normal

	# Reset the texture to the normal texture after flashing
	button.texture_normal = original_texture
	button.texture_pressed = original_pressed_texture

# Handle button clicks
func _on_button_pressed(button_index : int) -> void:
	if is_playing_sequence:
		return  # Prevent clicks during sequence playback

	# Play the respective sound for the pressed button
	var audio_player : AudioStreamPlayer2D = get_audio_player_for_button(button_index)
	audio_player.play()

	# Check if the player clicked the correct button
	if button_index == sound_sequence[sequence_position]:
		sequence_position += 1
		if sequence_position == sound_sequence.size():
			# Player completed the sequence correctly, increase score and sequence length
			score += 10  # Increase score
			print("Correct! Moving to the next round.")
			display_feedback("Correct!", Color(0, 1, 0))  # Green for correct
			update_score_label()  # Update the score display
			await start_next_round()
	else:
		# Player made a mistake, reset sequence and start over
		print("Wrong! Try again.")
		display_feedback("Wrong!", Color(1, 0, 0)) 
		await pause_on_mistake()
		sequence_position = 0
		play_sequence()
		update_score_label()  # Update the score display even on mistakes

# Function to update the score label
func update_score_label() -> void:
	score_label.text = "Score: " + str(score)

# Function to show feedback text
func display_feedback(message: String, color: Color) -> void:
	# Update the text and set the color
	feedback_label.text = message
	feedback_label.modulate = color  # Set text color
	feedback_label.visible = true  # Show the feedback

	# Hide the feedback after a short time
	await get_tree().create_timer(1.0).timeout  # Wait for 1 second
	feedback_label.visible = false  # Hide it again

# pause when the player gets it wrong
func pause_on_mistake() -> void:
	await get_tree().create_timer(2.0).timeout  # Pause for 2 seconds before retrying

func start_next_round():
	# Display "Next Round" message
	next_round_label.text = "Next Round!"
	next_round_label.visible = true

	# Wait for a short delay
	await get_tree().create_timer(2.0).timeout  # Pause for 2 seconds

	# Hide the message and generate the next sequence
	next_round_label.visible = false
	generate_sequence(sound_sequence.size() + 1)
	play_sequence()
