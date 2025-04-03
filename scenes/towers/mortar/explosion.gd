extends Node2D

@export var duration: float = 0.5
@export var max_size: float = 1.5

var elapsed_time: float = 0

func _ready():
	# Start an explosion sound if one exists
	if has_node("ExplosionSound"):
		$ExplosionSound.play()
	
	# Start with a small scale
	scale = Vector2(0.2, 0.2)
	
	# Add a light effect if it's in the scene
	if has_node("PointLight2D"):
		$PointLight2D.enabled = true

func _process(delta):
	elapsed_time += delta
	
	if elapsed_time >= duration:
		queue_free()
		return
	
	# Calculate progress (0 to 1)
	var progress = elapsed_time / duration
	
	# Grow quickly then fade out
	if progress < 0.3:
		# Grow phase
		var grow_factor = progress / 0.3
		scale = Vector2.ONE * max_size * grow_factor
		modulate.a = 1.0
	else:
		# Fade phase
		var fade_factor = 1.0 - ((progress - 0.3) / 0.7)
		scale = Vector2.ONE * max_size
		modulate.a = fade_factor
	
	# Optional: add some rotation for visual effect
	rotation += delta * 2.0
