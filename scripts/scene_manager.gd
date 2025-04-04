extends Node

var maps = {
	"autumn": preload("res://scenes/maps/map_autumn.tscn"),
	"spring": preload("res://scenes/maps/map_spring.tscn"),
	"summer": preload("res://scenes/maps/map_summer.tscn"),
	"winter": preload("res://scenes/maps/map_winter.tscn")
}

func transition_to_map(map_id):
	return maps[map_id].instantiate()
	
func get_random_map_sequence(count=3):
	# Get all map keys
	var map_keys = maps.keys()
	# Randomize the order
	map_keys.shuffle()
	# Return the first 'count' maps
	return map_keys.slice(0, count)
