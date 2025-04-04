extends Node

# Singleton to manage game speed globally
# This ensures all processes and physics obey the same speed settings

signal game_speed_changed(speed_multiplier)

enum SpeedMode {
	NORMAL = 1,
	DOUBLE = 2,
	TRIPLE = 3
}

var current_speed: SpeedMode = SpeedMode.NORMAL
var debug_mode: bool = false

func _ready():
	# Make this a singleton
	if get_parent() != get_tree().root:
		debug_print("GameSpeedManager should be an autoload singleton!")

func set_game_speed(speed: SpeedMode):
	if speed == current_speed:
		return
		
	debug_print("Changing game speed to " + str(speed) + "x")
	current_speed = speed
	
	# Set the global time scale
	Engine.time_scale = float(speed)
	
	# Emit signal for other nodes that might need to adjust
	emit_signal("game_speed_changed", speed)

func get_current_speed() -> SpeedMode:
	return current_speed
	
func get_current_speed_multiplier() -> float:
	return float(current_speed)

func reset_speed():
	set_game_speed(SpeedMode.NORMAL)

func debug_print(message):
	if debug_mode:
		print("[GameSpeedManager] " + message)