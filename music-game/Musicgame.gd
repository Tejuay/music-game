extends Node2D

# Declare variables
@export var sound_sequence : Array[int] = []  # Store indices (0, 1, 2, 3)
@export var sounds : Array = ["Button 1.mp3", "Button 2.mp3", "Button 3.mp3", "Button 4.mp3"]  # Sound file names
var sequence_position : int = 0
var is_playing_sequence : bool = false  # Prevent clicking during sequence playback
var score : int = 0  # Initialize score

# Declare buttons with onready to connect them when the scene is ready
@onready var button1 : TextureButton = $'Button 1'
@onready var button2 : TextureButton = $'Button 2'
@onready var button3 : TextureButton = $'Button 3'
@onready var button4 : TextureButton = $'Button 4'

# Texture for when the button is presse
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

func _ready():
	# Connect button signals with the index using bind() instead of directly passing an array
	button1.connect("pressed", Callable(self, "_on_button_pressed").bind(0))
	button2.connect("pressed", Callable(self, "_on_button_pressed").bind(1))
	button3.connect("pressed", Callable(self, "_on_button_pressed").bind(2))
	button4.connect("pressed", Callable(self, "_on_button_pressed").bind(3))

	# Generate the first sequence
	generate_sequence(3)  # Starting with a sequence of 3 sounds
	play_sequence()

	# Update the score display
	update_score_label()

	# Initially hide the feedback label
	feedback_label.visible = false

# Generate a random sequence of indices
func generate_sequence(length : int) -> void:
	sound_sequence.clear()
	for i in range(length):
		sound_sequence.append(randi() % sounds.size())  # Store indices

# Play the sequence for the player
func play_sequence() -> void:
	sequence_position = 0
	is_playing_sequence = true
	for index in sound_sequence:
		var sound : AudioStream = load("res://sounds/" + sounds[index]) as AudioStream
		var audio_player : AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(audio_player)
		audio_player.stream = sound
		audio_player.play()

		# Add visual feedback
		var button : TextureButton = get_node("Button " + str(index + 1)) as TextureButton
		flash_button(button)

		# Wait for each sound to play
		await get_tree().create_timer(1.0).timeout  # Assuming each sound takes 1 second

	is_playing_sequence = false  # Allow user to interact after the sequence is played

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

	# Check if the player clicked the correct button
	if button_index == sound_sequence[sequence_position]:
		sequence_position += 1
		if sequence_position == sound_sequence.size():
			# Player completed the sequence correctly, increase score and sequence length
			score += 10  # Increase score
			print("Correct! Moving to the next round.")
			display_feedback("Correct!", Color(0, 1, 0))  # Green for correct
			generate_sequence(sound_sequence.size() + 1)
			play_sequence()
			update_score_label()  # Update the score display
	else:
		# Player made a mistake, reset sequence and start over
		print("Wrong! Try again.")
		display_feedback("Wrong!", Color(1, 0, 0))  # Red for wrong
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
	feedback_label.modulate = color  # Set text color based on correct/incorrect
	feedback_label.visible = true  # Show the feedback

	# Hide the feedback after a short time
	await get_tree().create_timer(1.0).timeout  # Wait for 1 second
	feedback_label.visible = false  # Hide it again
