extends Node2D

@export var tower_scene: PackedScene
@export var tower_cost = 50
var currency = 100
var preview_tower = null

func _ready():
	if tower_scene == null:
		tower_scene = load("res://scenes/towers/mortar/mortar.tscn")

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
		
		add_child(tower)
		currency -= tower_cost
		
		# Update UI (we'll add this later)
		print("Currency: ", currency)  # For now just print
