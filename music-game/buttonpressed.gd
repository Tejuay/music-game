extends Node2D

@onready var button1 : TextureButton = $'Button 1'
@onready var button2 : TextureButton = $'Button 2'
@onready var button3 : TextureButton = $'Button 3'
@onready var button4 : TextureButton = $'Button 4'

func _ready():
	# Connect the "pressed" signal for each button
	button1.connect("pressed", Callable(self, "_on_button_pressed").bind(0))
	button2.connect("pressed", Callable(self, "_on_button_pressed").bind(1))
	button3.connect("pressed", Callable(self, "_on_button_pressed").bind(2))
	button4.connect("pressed", Callable(self, "_on_button_pressed").bind(3))

func _on_button_pressed(button_index: int) -> void:
	match button_index:
		0:
			print("Button 1 pressed")
		1:
			print("Button 2 pressed")
		2:
			print("Button 3 pressed")
		3:
			print("Button 4 pressed")
