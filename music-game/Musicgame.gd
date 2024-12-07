extends Node2D

# Declare variables
@export var sound_sequence : Array[int] = []  # Store indices (0, 1, 2, 3)
@export var sounds : Array = ["Button 1.mp3", "Button 2.mp3", "Button 3.mp3", "Button 4.mp3"]  # Sound file names
var sequence_position : int = 0
var is_playing_sequence : bool = false  # Prevent clicking during sequence playback

# Declare buttons with onready to connect them when the scene is ready
@onready var button1 : TextureButton = $'Button 1'
@onready var button2 : TextureButton = $'Button 2'
@onready var button3 : TextureButton = $'Button 3'
@onready var button4 : TextureButton = $'Button 4'

# Texture for when the button is pressed (assign this in the editor)
@export var pressed_texture : Texture  

func _ready():
	# Connect button signals with the index using bind() instead of directly passing an array
	button1.connect("pressed", Callable(self, "_on_button_pressed").bind(0))
	button2.connect("pressed", Callable(self, "_on_button_pressed").bind(1))
	button3.connect("pressed", Callable(self, "_on_button_pressed").bind(2))
	button4.connect("pressed", Callable(self, "_on_button_pressed").bind(3))

	# Generate the first sequence
	generate_sequence(3)  # Starting with a sequence of 3 sounds
	play_sequence()

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

		# Add visual feedback (flash button)
		var button : TextureButton = get_node("Button " + str(index + 1)) as TextureButton
		flash_button(button)

		# Wait for each sound to play (use await to handle asynchronous behavior)
		await get_tree().create_timer(1.0).timeout  # Assuming each sound takes 1 second

	is_playing_sequence = false  # Allow user to interact after the sequence is played

# Flash button when sound plays (using color modulation instead of texture change)
func flash_button(button : TextureButton) -> void:
	# Store the original color (normal state)
	var original_modulate = button.modulate

	# Set the button's color to a bright color for flashing effect
	button.modulate = Color(1, 0, 0)  # Flash with red color

	# Wait for a short time before returning to the original color
	await get_tree().create_timer(0.2).timeout
	
	# Reset the color back to the original color
	button.modulate = original_modulate

# Handle button clicks
func _on_button_pressed(button_index : int) -> void:
	if is_playing_sequence:
		return  # Prevent clicks during sequence playback

	# Check if the player clicked the correct button
	if button_index == sound_sequence[sequence_position]:
		sequence_position += 1
		if sequence_position == sound_sequence.size():
			# Player completed the sequence correctly, increase sequence length
			print("Correct! Moving to the next round.")
			generate_sequence(sound_sequence.size() + 1)
			play_sequence()
	else:
		# Player made a mistake, reset sequence and start over
		print("Wrong! Try again.")
		sequence_position = 0
		play_sequence()
