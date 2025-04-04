extends Node2D
@export var tower_scene: PackedScene
@export var tower_cost = 50
@export var base_health = 20
@export var debug_mode: bool = false

var currency = 100
var preview_tower = null
var current_base_health = 0
var game_speed_manager = null

@onready var shop = $TowerShop  # Reference to your TowerShop node
@onready var round_manager = $RoundManager
@onready var base_health_bar = $BaseHealthBar
@onready var speed_1x_button = $GameSpeedControl/Speed1xButton
@onready var speed_2x_button = $GameSpeedControl/Speed2xButton
@onready var speed_3x_button = $GameSpeedControl/Speed3xButton

signal base_damaged(health_remaining)
signal game_over

func _ready():
	debug_print("Map _ready called")
	
	# Initialize base health
	current_base_health = base_health
	
	# Check for GameSpeedManager singleton
	if Engine.has_singleton("GameSpeedManager"):
		game_speed_manager = Engine.get_singleton("GameSpeedManager")
	else:
		# Create a local instance for this scene
		game_speed_manager = load("res://scenes/maps/game_speed_manager.gd").new()
		game_speed_manager.debug_mode = debug_mode
		add_child(game_speed_manager)
		debug_print("Created local GameSpeedManager instance")
	
	# Connect speed control buttons
	if speed_1x_button and speed_2x_button and speed_3x_button:
		speed_1x_button.pressed.connect(_on_speed_1x_pressed)
		speed_2x_button.pressed.connect(_on_speed_2x_pressed)
		speed_3x_button.pressed.connect(_on_speed_3x_pressed)
	
	if has_node("TowerShop"):
		debug_print("TowerShop node found")
	else:
		debug_print("TowerShop node NOT found")
	if tower_scene == null:
		tower_scene = load("res://scenes/towers/mortar/mortar.tscn")
	
	# Connect to shop signal
	shop.tower_selected.connect(_on_tower_selected)
	
	# Update currency display
	shop.set_currency(currency)
	
	# Update base health display if we have it
	if base_health_bar:
		update_base_health_display()
	
	# Subscribe to enemy reaching end path
	var enemy_spawner = $EnemySpawner
	if enemy_spawner:
		debug_print("Connecting to enemy_reached_end signal")
		# This would be implemented in a more advanced version where we have 
		# a signal from the enemy_spawner or the path
		
	# Connect to round_manager signals
	round_manager.stage_completed.connect(_on_stage_completed)

func _on_start_round_button_pressed():
	get_node("DeckManager").start_level()
	debug_print("Button pressed!")
	if round_manager:
		debug_print("Starting round via round manager")
		round_manager.start_round()
	else:
		debug_print("Round manager not found")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Start showing tower preview when button is pressed
			show_tower_preview(get_global_mouse_position())
		else:
			# Place tower when button is released
			if preview_tower != null:
				place_tower(get_global_mouse_position())
				hide_tower_preview()
	
	# Update preview position when mouse moves while holding button
	if event is InputEventMouseMotion and preview_tower != null:
		preview_tower.global_position = get_global_mouse_position()
	
	# Keyboard shortcuts for game speed
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			_on_speed_1x_pressed()
		elif event.keycode == KEY_2:
			_on_speed_2x_pressed()
		elif event.keycode == KEY_3:
			_on_speed_3x_pressed()

func _on_tower_selected(tower_data):
	# Called when a tower is selected from the shop
	tower_scene = tower_data.scene
	tower_cost = tower_data.cost
	
	# Optionally start tower placement right away
	show_tower_preview(get_global_mouse_position())

func damage_base(amount):
	# Deduct health
	current_base_health -= amount
	
	# Ensure it doesn't go below zero
	current_base_health = max(0, current_base_health)
	
	# Update UI
	update_base_health_display()
	
	# Emit signal
	emit_signal("base_damaged", current_base_health)
	
	# Check if game over
	if current_base_health <= 0:
		emit_signal("game_over")
		# Maybe show game over screen or restart level

func update_base_health_display():
	if base_health_bar:
		base_health_bar.value = current_base_health
		base_health_bar.max_value = base_health
		
		# Update color based on health percentage
		var health_percent = float(current_base_health) / float(base_health)
		
		if health_percent > 0.6:
			base_health_bar.modulate = Color(0, 1, 0)  # Green
		elif health_percent > 0.3:
			base_health_bar.modulate = Color(1, 1, 0)  # Yellow
		else:
			base_health_bar.modulate = Color(1, 0, 0)  # Red

func heal_base(amount):
	current_base_health += amount
	current_base_health = min(current_base_health, base_health)
	update_base_health_display()

func _on_stage_completed():
	# When a stage is completed, maybe heal the base or give a currency bonus
	currency += 100
	shop.set_currency(currency)
	heal_base(5)  # Heal 5 health at end of stage

# Game speed control functions
func _on_speed_1x_pressed():
	if game_speed_manager:
		game_speed_manager.set_game_speed(game_speed_manager.SpeedMode.NORMAL)
	
	# Update button UI
	speed_1x_button.button_pressed = true
	speed_2x_button.button_pressed = false
	speed_3x_button.button_pressed = false

func _on_speed_2x_pressed():
	if game_speed_manager:
		game_speed_manager.set_game_speed(game_speed_manager.SpeedMode.DOUBLE)
	
	# Update button UI
	speed_1x_button.button_pressed = false
	speed_2x_button.button_pressed = true
	speed_3x_button.button_pressed = false

func _on_speed_3x_pressed():
	if game_speed_manager:
		game_speed_manager.set_game_speed(game_speed_manager.SpeedMode.TRIPLE)
	
	# Update button UI
	speed_1x_button.button_pressed = false
	speed_2x_button.button_pressed = false
	speed_3x_button.button_pressed = true

func show_tower_preview(position):
	# Create preview tower if we can afford it
	if currency >= tower_cost and preview_tower == null:
		# Instead of using the full tower, create a simplified preview
		preview_tower = Node2D.new()
		preview_tower.name = "TowerPreview"
		preview_tower.global_position = position
		
		# Create a sample tower to copy visuals from
		var sample_tower = tower_scene.instantiate()
		
		# Copy just the visual elements (Sprite nodes)
		copy_visual_elements(sample_tower, preview_tower)
		
		# Add the range indicator
		if sample_tower.has_node("Range") and sample_tower.get_node("Range").has_node("RangeSprite"):
			var range_sprite = sample_tower.get_node("Range/RangeSprite").duplicate()
			
			# Get the range value from the sample tower
			var range_radius = sample_tower.range_radius
			
			# Create a container for the range sprite
			var range_container = Node2D.new()
			range_container.name = "Range"
			range_container.add_child(range_sprite)
			
			# Set up the range sprite scale
			var texture_size = range_sprite.texture.get_size()
			var sprite_radius = texture_size.x / 2
			range_sprite.scale = Vector2(range_radius / sprite_radius, range_radius / sprite_radius)
			
			preview_tower.add_child(range_container)
		
		# Free the sample tower since we don't need it anymore
		sample_tower.queue_free()
		
		# Make the preview semi-transparent
		preview_tower.modulate = Color(1, 1, 1, 0.5)
		
		add_child(preview_tower)

func copy_visual_elements(source_node, target_node):
	# Copy sprite nodes from source to target
	for child in source_node.get_children():
		if child is Sprite2D:
			var sprite_copy = child.duplicate()
			target_node.add_child(sprite_copy)
		
		# Recursively copy sprites from child nodes
		# Skip Range node as we handle it separately
		if child.get_child_count() > 0 and child.name != "Range":
			var container = Node2D.new()
			container.name = child.name
			target_node.add_child(container)
			copy_visual_elements(child, container)

func hide_tower_preview():
	if preview_tower != null:
		preview_tower.queue_free()
		preview_tower = null

func place_tower(position):
	if currency >= tower_cost:
		var tower = tower_scene.instantiate()
		tower.global_position = position
		
		# Hide the range indicator on the placed tower
		if tower.has_node("Range"):
			tower.get_node("Range").visible = false
		
		# Add to towers group for targeting
		tower.add_to_group("towers")
		
		add_child(tower)
		currency -= tower_cost
		
		# Update shop currency
		shop.set_currency(currency)

func debug_print(message):
	if debug_mode:
		print("[Map.gd] " + message)
