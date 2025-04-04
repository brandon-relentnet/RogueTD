extends Node

var maps = {
	"map1": preload("res://scenes/maps/map_1.tscn")
}

func transition_to_map(map_id):
	return maps[map_id].instantiate()
