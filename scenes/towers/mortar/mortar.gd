extends Node2D

@export_group("Tower Properties")
@export var damage: float = 1000
@export var attack_speed: float = 0.7 # Attacks per second
@export var range_radius: float = 150
@export var projectile_scene: PackedScene
@export var projectile_height: float = 150 # Max height of arc
@export var projectile_travel_time: float = 0.7 # Time to reach target

var target = null
var attack_timer: float = 0
var can_fire: bool = true
var debug_mode: bool = false  # Set to true to enable debug prints

func _ready():
	# Get the sprite's texture size
	var sprite = $Range/RangeSprite
	var texture_size = sprite.texture.get_size()
	
	# Calculate the sprite's radius
	var sprite_radius = texture_size.x / 2 # Use width divided by 2
	
	# Set scale to match range_radius precisely
	sprite.scale = Vector2(range_radius / sprite_radius, range_radius / sprite_radius)
	
	# Set collision shape radius
	$Range/CollisionShape2D.shape.radius = range_radius
	
	# Start the targeting timer
	_start_target_refresh_timer()

func _process(delta):
	# If we can fire and have no target or target is invalid, find a new one
	if can_fire and (target == null or not is_instance_valid(target) or not target.is_inside_tree()):
		target = find_target()
		debug_print("Looking for new target, found: " + str(target))
	
	# If we have a target, attack when ready
	if target and is_instance_valid(target) and can_fire:
		# Make sure target is still valid and has the expected properties
		if target.has_method("take_damage"):
			if is_target_in_range(target):
				# Attack timer
				attack_timer += delta
				if attack_timer >= 1.0 / attack_speed:
					attack_timer = 0
					fire_mortar()
			else:
				debug_print("Target moved out of range")
				target = null
		else:
			# Target doesn't have expected methods, clear it
			debug_print("Target missing take_damage method")
			target = null

func _start_target_refresh_timer():
	# Create timer to periodically refresh target
	var timer = Timer.new()
	timer.wait_time = 1.0  # Check every second
	timer.one_shot = false
	timer.timeout.connect(_on_refresh_timer_timeout)
	add_child(timer)
	timer.start()

func _on_refresh_timer_timeout():
	# Only refresh if we can fire (not in the middle of attack)
	if can_fire:
		var old_target = target
		target = find_target()
		
		if old_target != target:
			debug_print("Target refreshed: " + str(target))

func find_target():
	var enemies = []
	
	# Try to find enemies using the Area2D Range node
	if has_node("Range"):
		var bodies = $Range.get_overlapping_bodies()
		debug_print("Range detected " + str(bodies.size()) + " overlapping bodies")
		
		for body in bodies:
			if body.get_parent() and body.get_parent().is_in_group("enemies"):
				enemies.append(body.get_parent())
	
	# Fallback method if no enemies found via Range detection
	if enemies.size() == 0:
		# Get all enemies in the scene and filter by distance
		var all_enemies = get_tree().get_nodes_in_group("enemies")
		debug_print("Found " + str(all_enemies.size()) + " total enemies in scene")
		
		for enemy in all_enemies:
			if is_instance_valid(enemy):
				var distance = global_position.distance_to(enemy.global_position)
				if distance <= range_radius:
					enemies.append(enemy)
	
	if enemies.size() > 0:
		# Sort enemies by distance or other criteria
		enemies.sort_custom(func(a, b): 
			return global_position.distance_to(a.global_position) < global_position.distance_to(b.global_position)
		)
		
		debug_print("Found " + str(enemies.size()) + " enemies in range")
		return enemies[0]
	
	debug_print("No targets found in range")
	return null

func fire_mortar():
	if target and is_instance_valid(target):
		debug_print("Firing at target: " + str(target))
		
		# Can't fire until projectile lands
		can_fire = false
		
		# Check if projectile_scene is set
		if projectile_scene == null:
			print("ERROR: projectile_scene is not set. Please assign it in the inspector.")
			can_fire = true
			return
		
		# Spawn projectile
		var projectile = projectile_scene.instantiate()
		get_parent().add_child(projectile)
		projectile.global_position = global_position
		
		# Set target position and pass the enemy reference
		var target_pos = target.global_position
		
		if projectile.has_method("setup"):
			projectile.setup(global_position, target_pos, projectile_height, 
				projectile_travel_time, damage, target)
		
		# Connect to projectile landed signal
		projectile.landed.connect(_on_projectile_landed)
		
		# Visual feedback
		if has_node("AnimationPlayer"):
			$AnimationPlayer.play("recoil")

func _on_projectile_landed():
	# After projectile lands, we can fire again
	debug_print("Projectile landed, can fire again")
	can_fire = true
	
	# First check if current target is still valid
	if not is_valid_target(target):
		debug_print("Current target no longer valid, finding new target")
		target = find_target()
	else:
		debug_print("Continuing to target: " + str(target))

func is_valid_target(current_target):
	if current_target == null or not is_instance_valid(current_target) or not current_target.is_inside_tree():
		return false
		
	if not current_target.has_method("take_damage"):
		return false
		
	if not is_target_in_range(current_target):
		return false
		
	return true

func is_target_in_range(current_target):
	var distance = global_position.distance_to(current_target.global_position)
	return distance <= range_radius

func debug_print(message):
	if debug_mode:
		print("[Mortar Tower] " + message)
