extends Node

var current_character = null

# Preload scenes
var character_select_scene = preload("res://scenes/ui/character_select/CharacterSelect.tscn")
var character_select_instance = null
var run_manager_scene = preload("res://scripts/run_manager.gd")
var run_manager = null
var game_ui_scene = preload("res://scenes/ui/GameUI.tscn")
var game_ui_instance = null

func _ready():
	# Show the main menu and hide other UI elements
	$UI/MainMenu.show()
	$UI/PauseMenu.hide()
	$UI/HUD.hide()
	
	# Connect main menu signals
	$UI/MainMenu.connect("play_button_pressed", Callable(self, "_on_main_menu_play_pressed"))
	$UI/MainMenu.connect("settings_button_pressed", Callable(self, "_on_settings_button_pressed"))
	$UI/MainMenu.connect("quit_button_pressed", Callable(self, "_on_quit_button_pressed"))
	
	# Create run manager
	run_manager = Node.new()
	run_manager.set_script(run_manager_scene)
	run_manager.name = "run_manager"  # Set a specific name so we can find it later
	add_child(run_manager)
	print("Run manager created with name: ", run_manager.name)
	
	# Connect run manager signals
	run_manager.connect("run_completed", Callable(self, "_on_run_completed"))

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
	
	# Hide existing UI elements
	$UI/HUD.hide()
	
	# Instantiate game UI if not already created
	if game_ui_instance == null:
		game_ui_instance = game_ui_scene.instantiate()
		$UI.add_child(game_ui_instance)
	else:
		game_ui_instance.show()
		
	# Start the run with the selected character
	run_manager.start_run(character_id)
	
func _on_run_completed(successful):
	# Clean up and return to the main menu
	if game_ui_instance:
		game_ui_instance.hide()
	$UI/MainMenu.show()
	
	# Make sure any map instance is freed
	if run_manager.current_map_instance:
		run_manager.current_map_instance.queue_free()
		run_manager.current_map_instance = null
		
	if successful:
		print("Run completed successfully!")
	else:
		print("Run failed!")
	
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
