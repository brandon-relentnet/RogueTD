extends Node2D

signal landed
var start_pos: Vector2
var target_pos: Vector2
var max_height: float
var travel_time: float
var damage: float
var elapsed_time: float = 0
var explosion_scene = preload("res://scenes/towers/mortar/explosion.tscn")
var targeted_enemy = null  # Store reference to the targeted enemy
@export var explosion_radius: float = 100.0

func _ready():
	visible = true

func setup(start: Vector2, target: Vector2, height: float, time: float, dmg: float, enemy = null):
	start_pos = start
	target_pos = target
	max_height = height
	travel_time = time
	damage = dmg
	targeted_enemy = enemy  # Store the enemy reference
	
	elapsed_time = 0

func _process(delta):
	elapsed_time += delta
	
	# Calculate how far along the path we are (0 to 1)
	var t = elapsed_time / travel_time
	
	if t >= 1.0:
		explode()
		return
	
	# Linear interpolation for x and z position
	var pos = start_pos.lerp(target_pos, t)
	
	# Parabolic arc for height (y position)
	var height_offset = 4.0 * max_height * t * (1.0 - t)
	
	# Apply the position
	global_position = pos
	
	# Scale the sprite based on height - INCREASES in size for top-down view
	var scale_factor = 0.5 + (height_offset / (max_height * 1.5))
	scale = Vector2(scale_factor, scale_factor)
	
	# Add shadow effect
	update_shadow(pos, scale_factor)
	
	# Rotate projectile for visual effect
	rotation += delta * 2.0

func update_shadow(pos: Vector2, scale_factor: float):
	if has_node("Shadow"):
		var shadow = $Shadow
		shadow.global_position = Vector2(pos.x, target_pos.y)
		shadow.scale = Vector2(0.5, 0.5)
		
		var height_percent = (scale_factor - 0.5) / ((4.0 * max_height) / (max_height * 1.5))
		shadow.modulate.a = max(0.1, 0.7 - (height_percent * 0.6))

func explode():
	# Spawn explosion and scale it to match the explosion radius
	var explosion = explosion_scene.instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	# Scale the explosion sprite to match the explosion radius
	scale_explosion_to_radius(explosion)
	
	# Apply damage using area method
	apply_area_damage()
	
	# Emit signal that projectile has landed
	landed.emit()
	
	# Remove this projectile
	queue_free()

func scale_explosion_to_radius(explosion):
	# Find the main sprite in the explosion scene
	var sprite = find_sprite_in_node(explosion)
	
	if sprite and sprite is Sprite2D:
		print("Found explosion sprite: ", sprite.name)
		
		# Get the sprite's texture size
		var texture_size = sprite.texture.get_size()
		print("Texture size: ", texture_size)
		
		# The sprite is 36x36, so its radius is 18 pixels
		# We need to calculate the scale to make it match our explosion_radius
		
		# Calculate the sprite's current radius (use the correct dimension)
		var sprite_radius = texture_size.x / 2  # 18.0 for your 36x36 image
		print("Sprite radius: ", sprite_radius)
		
		# Calculate scaling factor to match explosion_radius
		var scale_factor = explosion_radius / sprite_radius
		print("Scale factor: ", scale_factor)
		
		# Apply scaling to the sprite directly 
		sprite.scale = Vector2(scale_factor, scale_factor)
		
		print("Scaled explosion sprite to radius: ", explosion_radius)
	else:
		print("Could not find sprite in explosion scene to scale")

# Helper function to find a Sprite2D node in a scene
func find_sprite_in_node(node):
	# Check if this node is a Sprite2D
	if node is Sprite2D:
		return node
	
	# Recursively check children
	for child in node.get_children():
		var result = find_sprite_in_node(child)
		if result:
			return result
	
	return null

func apply_area_damage():
	# Simple distance-based detection (no physics needed)
	var hit_count = 0
	
	# Find all enemies in the scene
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		# Check if we can get distance
		if is_instance_valid(enemy) and enemy.has_method("take_damage"):
			var distance = global_position.distance_to(enemy.global_position)
			
			if distance <= explosion_radius:
				enemy.take_damage(damage)
				hit_count += 1
	
	print("Simple distance method hit ", hit_count, " enemies")
	return hit_count > 0
