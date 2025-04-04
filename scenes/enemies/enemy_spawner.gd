extends Node2D

@export var enemy_scene: PackedScene
@export var boss_enemy_scene: PackedScene
@export var spawn_interval_base = 0.5
@export var debug_mode: bool = false

var enemies_to_spawn = 0
var enemies_spawned = 0
var timer = 0
var is_spawning = false
var round_manager = null
var spawn_interval = 0.5
var current_wave_enemies = []
var available_enemy_types = []

func _ready():
	if enemy_scene == null:
		enemy_scene = load("res://scenes/enemies/enemy.tscn")
	
	if boss_enemy_scene == null:
		boss_enemy_scene = enemy_scene  # Fallback to regular enemy if no boss specified
		
	# Initialize available enemy types
	setup_enemy_types()
	
	# Use a timer to find the RoundManager after a brief delay
	var timer = Timer.new()
	timer.wait_time = 0.1  # Short delay to ensure RoundManager is initialized
	timer.one_shot = true
	timer.timeout.connect(find_round_manager)
	add_child(timer)
	timer.start()

func setup_enemy_types():
	# Add more enemy types as they're implemented
	available_enemy_types = [
		{
			"scene": enemy_scene,
			"name": "Regular",
			"min_stage": 1,
			"health_modifier": 1.0,
			"speed_modifier": 1.0,
			"weight": 100
		}
		# You can add more enemy types here as you develop them
		# Example:
		# {
		#    "scene": preload("res://scenes/enemies/fast_enemy.tscn"),
		#    "name": "Fast",
		#    "min_stage": 1,  # Stage when this enemy starts appearing
		#    "health_modifier": 0.7,  # Lower health
		#    "speed_modifier": 1.5,   # Higher speed
		#    "weight": 30  # Relative chance of spawning
		# }
	]

func find_round_manager():
	debug_print("Looking for RoundManager...")
	var round_managers = get_tree().get_nodes_in_group("round_manager")
	debug_print(str(round_managers.size()) + " round managers")
	
	if round_managers.size() > 0:
		round_manager = round_managers[0]
		round_manager.round_started.connect(_on_round_started)
		debug_print("Successfully connected to RoundManager")
	else:
		debug_print("ERROR: Could not find RoundManager!")
		
func _process(delta):
	if is_spawning and enemies_spawned < enemies_to_spawn:
		timer += delta
		if timer >= spawn_interval:
			spawn_enemy()
			timer = 0
	
	# If all enemies have been spawned and none are left, end the round
	if is_spawning and enemies_spawned >= enemies_to_spawn:
		# Check if there are any enemies left in the scene
		var enemies = get_tree().get_nodes_in_group("enemies")
		if enemies.size() == 0:
			is_spawning = false
			if round_manager:
				round_manager.end_round()
			
func _on_round_started():
	# Get difficulty settings from round manager
	var current_round = round_manager.get_current_round()
	var current_stage = round_manager.get_current_stage()
	var is_boss_round = round_manager.is_current_boss_round()
	
	# Determine enemy count based on round manager's calculation
	enemies_to_spawn = round_manager.get_enemy_count()
	
	# Adjust spawn interval based on enemy count (more enemies = faster spawning)
	spawn_interval = spawn_interval_base * (1.0 / (1.0 + (current_round - 1) * 0.05))
	
	# Pre-determine the types of enemies to spawn in this wave
	current_wave_enemies = []
	
	for i in range(enemies_to_spawn):
		if is_boss_round and i == enemies_to_spawn - 1:
			# Last enemy in a boss round is the boss
			current_wave_enemies.append("boss")
		else:
			# Regular selection of enemy types based on weighted chance
			current_wave_enemies.append(select_enemy_type(current_stage))
	
	debug_print("Spawning " + str(enemies_to_spawn) + " enemies for round " + str(current_round))
	
	# Reset and start spawning
	enemies_spawned = 0
	is_spawning = true
	timer = 0

func select_enemy_type(current_stage):
	# Filter enemies available for the current stage
	var available_types = []
	var total_weight = 0
	
	for enemy_type in available_enemy_types:
		if enemy_type.min_stage <= current_stage:
			available_types.append(enemy_type)
			total_weight += enemy_type.weight
	
	# Weighted random selection
	var random_value = randi() % total_weight
	var cumulative_weight = 0
	
	for enemy_type in available_types:
		cumulative_weight += enemy_type.weight
		if random_value < cumulative_weight:
			return enemy_type.name
	
	# Fallback to first type if something goes wrong
	return available_types[0].name if available_types.size() > 0 else "Regular"

func spawn_enemy():
	debug_print("Spawning enemy...")
	
	# Choose which enemy type to spawn
	var enemy_type = current_wave_enemies[enemies_spawned]
	var spawn_scene = null
	var health_mod = 1.0
	var speed_mod = 1.0
	
	if enemy_type == "boss":
		spawn_scene = boss_enemy_scene
		health_mod = 3.0
		speed_mod = 0.8
	else:
		# Find the enemy type data
		for type in available_enemy_types:
			if type.name == enemy_type:
				spawn_scene = type.scene
				health_mod = type.health_modifier
				speed_mod = type.speed_modifier
				break
	
	# Fallback if something goes wrong
	if spawn_scene == null:
		spawn_scene = enemy_scene
	
	# Instantiate the enemy
	var enemy = spawn_scene.instantiate()
	
	# Apply difficulty modifiers from round manager
	enemy.health = int(enemy.health * round_manager.get_enemy_health_multiplier() * health_mod)
	enemy.max_health = enemy.health
	enemy.speed = enemy.speed * round_manager.get_enemy_speed_multiplier() * speed_mod
	
	# Add visual indicator for boss
	if enemy_type == "boss":
		enemy.modulate = Color(1.0, 0.5, 0.5)  # Reddish tint for bosses
		enemy.scale = Vector2(1.5, 1.5)        # Make boss bigger
		
	debug_print("Enemy instantiated, adding to path...")
	$"../EnemyPath".add_child(enemy)
	debug_print("Enemy added to path")
	enemies_spawned += 1

func debug_print(message):
	if debug_mode:
		print("[EnemySpawner] " + message)
