extends Control

# Signal for map selection
signal play_button_pressed(map_id)
signal settings_button_pressed
signal quit_button_pressed

# Reference nodes
@onready var play_button = $MarginContainer/VBoxContainer/MenuButtons/PlayButton
@onready var settings_button = $MarginContainer/VBoxContainer/MenuButtons/SettingsButton
@onready var quit_button = $MarginContainer/VBoxContainer/MenuButtons/QuitButton
@onready var map_selection = $MarginContainer/VBoxContainer/MapSelection
@onready var map1_button = $MarginContainer/VBoxContainer/MapSelection/Map1
@onready var map2_button = $MarginContainer/VBoxContainer/MapSelection/Map2
@onready var map3_button = $MarginContainer/VBoxContainer/MapSelection/Map3

func _ready():
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	map1_button.pressed.connect(_on_map1_selected)
	map2_button.pressed.connect(_on_map2_selected)
	map3_button.pressed.connect(_on_map3_selected)
	
	# Initially hide map selection
	map_selection.hide()

func _on_play_pressed():
	# Show map selection, hide main buttons
	map_selection.show()
	
	# Optionally animate this transition
	# $AnimationPlayer.play("to_map_selection")

func _on_settings_pressed():
	emit_signal("settings_button_pressed")

func _on_quit_pressed():
	emit_signal("quit_button_pressed")

func _on_map1_selected():
	emit_signal("play_button_pressed", "map1")

func _on_map2_selected():
	emit_signal("play_button_pressed", "map2")

func _on_map3_selected():
	emit_signal("play_button_pressed", "map3")
