extends Node2D

@onready var start_button : TextureButton = $Play
@onready var exit_button : TextureButton = $Exit

func _ready():
	# Connect the buttons to their respective actions
	start_button.connect("pressed", Callable(self, "_on_start_button_pressed"))
	
	# Check if the exit button exists and connect its signal
	if has_node("Exit"):
		exit_button.connect("pressed", Callable(self, "_on_exit_button_pressed"))

# Function that runs when the Start Button is pressed
func _on_start_button_pressed():
	# Load and change to the main game scene
	get_tree().change_scene_to_file("res://Main.tscn")  # Make sure the path to the game scene is correct

func _on_exit_button_pressed():
	# Quit the game
	get_tree().quit()
