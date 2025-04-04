extends Node

var current_map = null

func _ready():
	$UI/MainMenu.show()
	$UI/PauseMenu.hide()
	$UI/HUD.hide()
	
	$UI/MainMenu.connect("play_button_pressed", Callable(self, "_on_play_button_pressed"))
	$UI/MainMenu.connect("settings_button_pressed", Callable(self, "_on_settings_button_pressed"))
	$UI/MainMenu.connect("quit_button_pressed", Callable(self, "_on_quit_button_pressed"))
	
func _on_play_button_pressed(map_id):
	$UI/MainMenu.hide()
	
	$UI/HUD.show()
	
	load_map(map_id)
	
func load_map(map_id):
	if current_map != null:
		current_map.queue_free()
		current_map = null
		
	var map_scene = load("res://scenes/maps/" + map_id + ".tscn")
	current_map = map_scene.instantiate()
	
	$GameWorld.add_child(current_map)
	
	current_map.connect("round_completed", Callable(self, "_on_round_completed"))
	
func _on_settings_button_pressed():
	pass
	
func _on_quit_button_pressed():
	get_tree().quit()
	
func _input(event):
	if event.is_action_pressed("ui_cancel") and current_map != null:
			toggle_pause()
			
func toggle_pause():
	var paused = !get_tree().paused
	get_tree().paused = paused
	$UI/PauseMenu.visible = paused
	
