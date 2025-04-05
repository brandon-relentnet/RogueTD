extends Node

# Run properties
var current_character = ""
var map_sequence = []
var current_map_index = 0
var current_map_instance = null

# Card database and deck manager
var card_database
var deck_manager

signal run_started(character_id)
signal map_completed(map_id)
signal run_completed(successful)

func _ready():
	# Create card database
	card_database = Node.new()
	card_database.set_script(load("res://scripts/cards/card_database.gd"))
	card_database.name = "CardDatabase"
	add_child(card_database)
	
	# Create deck manager
	deck_manager = Node.new()
	deck_manager.set_script(load("res://scripts/cards/deck_manager.gd"))
	deck_manager.name = "DeckManager"
	add_child(deck_manager)
	
	print("Run manager initialized with card database and deck manager")

# Start a new run with the given character
func start_run(character_id):
	current_character = character_id
	
	# Generate random map sequence
	var scene_manager = get_node("/root/Main/SceneManager")
	if scene_manager:
		map_sequence = scene_manager.get_random_map_sequence(3)
	else:
		push_error("Could not find SceneManager node")
		map_sequence = ["autumn", "winter", "spring"]  # Fallback sequence
		
	current_map_index = 0
	
	print("Starting run with character: ", character_id)
	print("Map sequence: ", map_sequence)
	
	# Initialize deck with character's starter cards
	deck_manager.initialize_deck(character_id)
	
	# Load the first map
	load_current_map()
	
	emit_signal("run_started", character_id)
	
# Load the current map based on the current_map_index
func load_current_map():
	# Clear any existing map
	if current_map_instance:
		current_map_instance.queue_free()
	
	# Get the current map ID
	var current_map_id = map_sequence[current_map_index]
	
	# Get scene manager
	var scene_manager = get_node_or_null("/root/Main/SceneManager")
	if not scene_manager:
		push_error("Could not find SceneManager node")
		return
		
	# Instantiate the map
	current_map_instance = scene_manager.transition_to_map(current_map_id)
	
	# Add "Next Map" button for testing
	add_next_map_button(current_map_instance)
	
	# Add to the game world
	var game_world = get_node_or_null("/root/Main/GameWorld")
	if game_world:
		game_world.add_child(current_map_instance)
		print("Loaded map: ", current_map_id)
	else:
		push_error("Could not find GameWorld node")

# Add a "Next Map" button for testing
func add_next_map_button(map_instance):
	# Create a CanvasLayer to ensure the button is always on top
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10  # Put it on a high layer to ensure it's on top
	map_instance.add_child(canvas_layer)
	
	# Create a panel to make the button more visible
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(120, 100)
	panel.size = Vector2(200, 100)
	canvas_layer.add_child(panel)
	
	# Create a VBox to hold button and label
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	# Add a label to indicate what to do
	var label = Label.new()
	label.text = "Testing Map Navigation"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	# Create the button
	var button = Button.new()
	button.text = "NEXT MAP"
	button.size = Vector2(160, 50)
	button.pressed.connect(Callable(self, "_on_next_map_button_pressed"))
	vbox.add_child(button)
	
	print("Next Map button added to map")

# Handle next map button press
func _on_next_map_button_pressed():
	print("Next Map button pressed!")
	advance_to_next_map()

# Advance to the next map in sequence
func advance_to_next_map():
	# Complete current map
	emit_signal("map_completed", map_sequence[current_map_index])
	
	# Increment the map index
	current_map_index += 1
	
	# Check if run is complete
	if current_map_index >= map_sequence.size():
		print("Run completed!")
		emit_signal("run_completed", true)
		return
	
	# Load the next map
	load_current_map()

# End the current run
func end_run(successful = false):
	if current_map_instance:
		current_map_instance.queue_free()
		current_map_instance = null
	
	emit_signal("run_completed", successful)
