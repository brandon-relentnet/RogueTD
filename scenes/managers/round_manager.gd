extends Node

signal round_started
signal round_ended
signal level_completed
signal stage_completed

@export var debug_mode: bool = false

# Stage structure
@export var rounds_per_level = 5
@export var levels_per_stage = 4
@export var current_stage = 1

# Current progress tracking
var current_round = 0
var current_level = 1
var is_round_active = false
var is_boss_round = false

# Enemy configuration for spawning
var enemy_count_base = 10
var enemy_health_multiplier = 1.0
var enemy_speed_multiplier = 1.0

func _ready():
	add_to_group("round_manager")
	
func start_round():
	if is_round_active:
		debug_print("Cannot start round - round already in progress")
		return
		
	# Increase round counter
	current_round += 1
	
	# Check if this is a boss round
	is_boss_round = (current_round % rounds_per_level == 0 && 
					 current_level % levels_per_stage == 0)
					 
	# Set round as active
	is_round_active = true
	
	# Calculate difficulty scaling for this round
	calculate_difficulty()
	
	# Notify listeners that round has started
	emit_signal("round_started")
	
	debug_print("Stage " + str(current_stage) + ", Level " + str(current_level) + 
				", Round " + str(current_round) + " started!" + 
				(" (BOSS ROUND)" if is_boss_round else ""))

func end_round():
	is_round_active = false
	debug_print("Round " + str(current_round) + " completed!")
	
	# Check if level is completed
	if current_round % rounds_per_level == 0:
		current_level += 1
		debug_print("Level completed! Moving to level " + str(current_level))
		emit_signal("level_completed")
		
		# Check if stage is completed
		if current_level > levels_per_stage:
			current_stage += 1
			current_level = 1
			debug_print("Stage completed! Moving to stage " + str(current_stage))
			emit_signal("stage_completed")
	
	emit_signal("round_ended")
	
func calculate_difficulty():
	# Base enemy count scales with round and stage
	var round_in_level = (current_round - 1) % rounds_per_level + 1
	enemy_count_base = 10 + (round_in_level - 1) * 2 + (current_level - 1) * 5 + (current_stage - 1) * 10
	
	# Health scales with level and stage
	enemy_health_multiplier = 1.0 + (current_level - 1) * 0.2 + (current_stage - 1) * 0.5
	
	# Speed scales slightly with rounds and levels
	enemy_speed_multiplier = 1.0 + (round_in_level - 1) * 0.05 + (current_level - 1) * 0.1
	
	# Boss rounds have fewer but stronger enemies
	if is_boss_round:
		enemy_count_base = max(1, enemy_count_base / 3)
		enemy_health_multiplier *= 3.0
		enemy_speed_multiplier *= 0.8  # Bosses are slower but tougher
	
	debug_print("Difficulty: " + str(enemy_count_base) + " enemies with " +
				str(enemy_health_multiplier) + "x health and " +
				str(enemy_speed_multiplier) + "x speed")

func get_current_round():
	return current_round
	
func get_current_level():
	return current_level
	
func get_current_stage():
	return current_stage
	
func is_round_in_progress():
	return is_round_active
	
func get_enemy_count():
	return enemy_count_base
	
func get_enemy_health_multiplier():
	return enemy_health_multiplier
	
func get_enemy_speed_multiplier():
	return enemy_speed_multiplier
	
func is_current_boss_round():
	return is_boss_round
	
func debug_print(message):
	if debug_mode:
		print("[RoundManager] " + message)
