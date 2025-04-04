extends Node

signal round_started
signal round_ended

@export var total_rounds = 2
var debug_mode: bool = false

var current_round = 0
var is_round_active = false

func _ready():
	add_to_group("round_manager")
	
func start_round():
	if current_round >= total_rounds:
		debug_print("All rounds completed!")
		return
		
	current_round += 1
	is_round_active = true
	
	# Notify listeners that round has started
	emit_signal("round_started")
	
	debug_print("Round " + str(current_round) + " started!")

func end_round():
	is_round_active = false
	debug_print("Round " + str(current_round) + " completed!")
	emit_signal("round_ended")
	
func get_current_round():
	return current_round
	
func is_round_in_progress():
	return is_round_active
	
func debug_print(message, args=[]): # Or use simple function without variadic arguments
	if debug_mode:
		var to_print = ["[Map.gd]", message]
		if args.size() > 0:
			to_print.append_array(args)
		print(to_print)
