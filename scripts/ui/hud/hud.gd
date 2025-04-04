extends Control

@onready var run_info_label = $MarginContainer/HBoxContainer/RunInfoLabel
@onready var return_to_menu_button = $MarginContainer/HBoxContainer/ReturnToMenuButton

var current_character = "None"
var current_map_index = 0
var map_count = 3

func _ready():
	# Connect button signal
	return_to_menu_button.pressed.connect(_on_return_to_menu_pressed)
	
	# We'll connect to the run manager's signals once it's available
	# Since we're loaded before the run manager is created, we'll do this in _process
	
	# Update the HUD
	update_hud()
	
func _process(_delta):
	# Try to connect to the run manager if we haven't already
	if not is_connected_to_run_manager and get_node_or_null("/root/Main/run_manager") != null:
		connect_to_run_manager()
		
var is_connected_to_run_manager = false

func connect_to_run_manager():
	var run_manager = get_node_or_null("/root/Main/run_manager")
	if run_manager:
		run_manager.run_started.connect(_on_run_started)
		run_manager.map_completed.connect(_on_map_completed)
		is_connected_to_run_manager = true
		print("HUD connected to run manager")

func _on_run_started(character_id):
	current_character = character_id
	current_map_index = 1
	update_hud()

func _on_map_completed(map_id):
	current_map_index += 1
	update_hud()

func update_hud():
	run_info_label.text = "Character: %s | Map: %d/%d" % [current_character, current_map_index, map_count]

func _on_return_to_menu_pressed():
	# End the current run and return to menu
	var run_manager = get_node_or_null("/root/Main/run_manager")
	if run_manager:
		run_manager.end_run(false)
	else:
		print("Could not find run_manager node")
