extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval = 0.5
@export var enemy_count_round1 = 10
@export var enemy_count_round2 = 15

var enemies_to_spawn = 0
var enemies_spawned = 0
var timer = 0
var is_spawning = false
var round_manager = null
var debug_mode: bool = false

func _ready():
	if enemy_scene == null:
		enemy_scene = load("res://scenes/enemies/enemy.tscn")
	
	# Use a timer to find the RoundManager after a brief delay
	var timer = Timer.new()
	timer.wait_time = 0.1  # Short delay to ensure RoundManager is initialized
	timer.one_shot = true
	timer.timeout.connect(find_round_manager)
	add_child(timer)
	timer.start()

func find_round_manager():
	debug_print("Looking for RoundManager...")
	var round_managers = get_tree().get_nodes_in_group("round_manager")
	debug_print(round_managers.size(), "round managers")
	
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
	# Determine enemy count based on current round
	var current_round = round_manager.get_current_round()
	
	# Debug debug_print to check what's happening
	debug_print("Enemy spawner received round start signal, round: ", current_round)
	
	if current_round == 1:
		enemies_to_spawn = enemy_count_round1
	else:
		enemies_to_spawn = enemy_count_round2
	
	debug_print("Will spawn ", enemies_to_spawn)
	
	enemies_spawned = 0
	is_spawning = true
	timer = 0  # Reset timer to start spawning immediately
	
func spawn_enemy():
	debug_print("Spawning enemy...")
	var enemy = enemy_scene.instantiate()
	debug_print("Enemy instantiated, adding to path...")
	$"../EnemyPath".add_child(enemy)
	debug_print("Enemy added to path")
	enemies_spawned += 1

func debug_print(message, args=[]): # Or use simple function without variadic arguments
	if debug_mode:
		var to_print = ["[Map.gd]", message]
		if args.size() > 0:
			to_print.append_array(args)
		print(to_print)
