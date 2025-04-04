extends PathFollow2D

@export var speed = 50
@export var health = 100
@export var max_health = 100
@export var reward = 10
@export var damage_to_base = 1

@onready var sprite = $Sprite2D

var flashing = false
var original_modulate = Color.WHITE
var game_speed_manager = null
var base_speed = 0

func _ready():
	progress = 0
	loop = false
	add_to_group("enemies")
	
	# Cache original color for damage flashing
	if sprite:
		original_modulate = sprite.modulate
	
	# Store the base speed
	base_speed = speed
	
	# Get reference to game speed manager if available
	if Engine.has_singleton("GameSpeedManager"):
		game_speed_manager = Engine.get_singleton("GameSpeedManager")
		game_speed_manager.game_speed_changed.connect(_on_game_speed_changed)
		
		# Apply current speed
		_on_game_speed_changed(game_speed_manager.get_current_speed_multiplier())

func _process(delta):
	# The delta is already scaled by Engine.time_scale, but we use our own system for consistency
	progress += speed * delta
	
	# Check if enemy reached the end
	if progress_ratio >= 1.0:
		reached_end()
	
	# Update the health bar if we have one
	if has_node("HealthBar"):
		$HealthBar.visible = health < max_health

func _on_game_speed_changed(speed_multiplier):
	# We don't need to modify our speed since delta is already scaled by Engine.time_scale
	# This function is mainly for other types of adjustments if needed
	pass

func take_damage(amount):
	# Calculate actual damage after any modifiers
	var actual_damage = amount
	
	# Apply damage
	health -= actual_damage
	
	# Flash effect on damage
	flash_damage()
	
	# Die if health depleted
	if health <= 0:
		die()
		
func flash_damage():
	# Don't start another flash if one is in progress
	if flashing:
		return
		
	flashing = true
	
	# Flash red
	if sprite:
		sprite.modulate = Color(1.5, 0.5, 0.5)
	
	# Reset after short delay
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(func():
		if sprite and is_instance_valid(sprite):
			sprite.modulate = original_modulate
		flashing = false
	)
		
func die():
	# Give player reward for killing enemy
	give_reward()
	
	# Optional: Play death animation or particle effect
	# ...
	
	# Remove the enemy
	queue_free()
		
func reached_end():
	# Damage the player's base
	deal_damage_to_base()
	
	# Remove the enemy
	queue_free()

func give_reward():
	# Get the map node (typically the parent of our path)
	var map = get_parent().get_parent()
	
	# If map has a currency variable, add the reward
	if map and "currency" in map:
		map.currency += reward
		
		# Update shop display if available
		if map.has_node("TowerShop"):
			map.get_node("TowerShop").set_currency(map.currency)

func deal_damage_to_base():
	# Get the map node (typically the parent of our path)
	var map = get_parent().get_parent()
	
	# If map has damage_base method, call it
	if map and map.has_method("damage_base"):
		map.damage_base(damage_to_base)
	else:
		# Fallback - just print a message
		print("Base took " + str(damage_to_base) + " damage!")
