extends PathFollow2D

@export var speed = 50
@export var health = 100
@export var max_health = 100

func _ready():
	progress = 0
	loop = false
	add_to_group("enemies")
	
func _process(delta):
	progress += speed * delta
	
	if progress_ratio >= 1.0:
		reached_end()
		
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()
		
func die():
		queue_free()
		
func reached_end():
	queue_free()
