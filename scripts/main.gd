extends Node

var current_character = null

# Preload scenes
var character_select_scene = preload("res://scenes/ui/character_select/CharacterSelect.tscn")
var character_select_instance = null

func _ready():
	# Show the main menu and hide other UI elements
	$UI/MainMenu.show()
	$UI/PauseMenu.hide()
	$UI/HUD.hide()
	
	# Connect main menu signals
	$UI/MainMenu.connect("play_button_pressed", Callable(self, "_on_main_menu_play_pressed"))
	$UI/MainMenu.connect("settings_button_pressed", Callable(self, "_on_settings_button_pressed"))
	$UI/MainMenu.connect("quit_button_pressed", Callable(self, "_on_quit_button_pressed"))

func _on_main_menu_play_pressed():
	# Instead of loading map directly, show character selection
	$UI/MainMenu.hide()
	
	# Instantiate character select if not already
	if character_select_instance == null:
		character_select_instance = character_select_scene.instantiate()
		character_select_instance.connect("character_selected", Callable(self, "_on_character_selected"))
		character_select_instance.connect("back_pressed", Callable(self, "_on_character_select_back"))
		$UI.add_child(character_select_instance)
	else:
		character_select_instance.show()

func _on_character_select_back():
	# Hide character select and show main menu
	character_select_instance.hide()
	$UI/MainMenu.show()

func _on_character_selected(character_id):
	# Store selected character
	current_character = character_id
	
	# Hide character select
	character_select_instance.hide()
	
	# Show HUD
	$UI/HUD.show()

	# In a more complex implementation, you'd set up the game state based on character selection:
	# - Load character-specific towers
	# - Initialize starting deck
	print("Starting game with character: ", character_id)
	
func _on_settings_button_pressed():
	# Implement settings menu
	pass
	
func _on_quit_button_pressed():
	get_tree().quit()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
			
func toggle_pause():
	var paused = !get_tree().paused
	get_tree().paused = paused
	$UI/PauseMenu.visible = paused
