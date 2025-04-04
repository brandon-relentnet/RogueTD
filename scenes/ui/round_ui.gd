extends CanvasLayer

@onready var start_button = $StartRoundButton

var round_manager = null

func _ready():
	# Find the round manager
	print("RoundUI ready, looking for RoundManager...")
	var round_managers = get_tree().get_nodes_in_group("round_manager")
	print("Found ", round_managers.size(), " round managers")
	if round_managers.size() > 0:
		round_manager = round_managers[0]
		print("Connecting to RoundManager signals")
		round_manager = round_managers[0]
		# Connect signals from round manager
		round_manager.round_started.connect(_on_round_started)
		round_manager.round_ended.connect(_on_round_ended)
		# Connect button signal
		start_button.pressed.connect(_on_start_round_button_pressed)
	else:
		print("ERROR: No RoundManager found!")
	
	

func _on_start_round_button_pressed():
	print("Start Round button pressed!")
	if round_manager and !round_manager.is_round_in_progress():
		print("Calling start_round() on RoundManager")
		round_manager.start_round()
	else:
		print("Cannot start round: ", "round_manager null? ", round_manager == null, 
			  ", is in progress? ", round_manager.is_round_in_progress() if round_manager else "N/A")

func _on_round_started():
	start_button.disabled = true
	start_button.text = "Round In Progress"

func _on_round_ended():
	start_button.disabled = false
	
	if round_manager.get_current_round() >= round_manager.total_rounds:
		start_button.text = "All Rounds Complete!"
		start_button.disabled = true
	else:
		start_button.text = "Start Next Round"
