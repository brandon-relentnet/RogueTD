extends Control

# Signal for map selection
signal play_button_pressed
signal settings_button_pressed
signal quit_button_pressed

# Reference nodes
@onready var play_button = $MarginContainer/VBoxContainer/MenuButtons/PlayButton
@onready var settings_button = $MarginContainer/VBoxContainer/MenuButtons/SettingsButton
@onready var quit_button = $MarginContainer/VBoxContainer/MenuButtons/QuitButton

func _ready():
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	emit_signal("play_button_pressed")

func _on_settings_pressed():
	emit_signal("settings_button_pressed")

func _on_quit_pressed():
	emit_signal("quit_button_pressed")
