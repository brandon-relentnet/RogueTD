extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval = 0.1
@export var enemy_count = 50

var enemies_spawned = 0
var timer = 0

func _ready():
	if enemy_scene == null:
		enemy_scene = load("res://scenes/enemies/enemy.tscn")
		
func _process(delta):
	if enemies_spawned < enemy_count:
		timer += delta
		if timer >= spawn_interval:
			spawn_enemy()
			timer = 0
			
func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	$"../EnemyPath".add_child(enemy)
	enemies_spawned += 1
