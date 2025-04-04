extends Node2D

@onready var progress_bar = $ProgressBar

func _ready():
	# Make sure the progress bar is properly configured
	if progress_bar:
		progress_bar.min_value = 0
		progress_bar.max_value = 1
		progress_bar.show_percentage = false
		progress_bar.value = 1
	
	# Hide health bar by default for regular enemies
	visible = false

func _process(delta):
	# Get parent node (the enemy)
	var parent = get_parent()
	
	if parent.has_method("take_damage") and "health" in parent and "max_health" in parent:
		# Calculate health percentage
		var health_percent = float(parent.health) / float(parent.max_health)
		
		# Update progress bar
		progress_bar.value = health_percent
		
		# Show health bar if health is below max
		if health_percent < 1.0:
			visible = true
		
		# Set color based on health percentage
		var bar_color = Color(1, 0, 0)  # Red for low health
		
		if health_percent > 0.6:
			bar_color = Color(0, 1, 0)  # Green for high health
		elif health_percent > 0.3:
			bar_color = Color(1, 1, 0)  # Yellow for medium health
			
		# Apply color
		progress_bar.modulate = bar_color