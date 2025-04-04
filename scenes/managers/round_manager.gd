extends Node

signal round_started
signal round_ended

@export var total_rounds = 2

var current_round = 0
var is_round_active = false

func _ready():
	add_to_group("round_manager")
	
func start_round():
	if current_round >= total_rounds:
		print("All rounds completed!")
		return
		
	current_round += 1
	is_round_active = true
	
	# Notify listeners that round has started
	emit_signal("round_started")
	
	print("Round " + str(current_round) + " started!")

func end_round():
	is_round_active = false
	print("Round " + str(current_round) + " completed!")
	emit_signal("round_ended")
	
func get_current_round():
	return current_round
	
func is_round_in_progress():
	return is_round_active
