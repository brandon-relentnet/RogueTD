extends CanvasLayer

@onready var start_button = $StartRoundButton
@onready var stage_label = $StageLabel
@onready var level_label = $LevelLabel
@onready var round_label = $RoundLabel
@onready var state_label = $StateLabel

var round_manager = null
var debug_mode: bool = false

func _ready():
	# Find the round manager
	debug_print("RoundUI ready, looking for RoundManager...")
	var round_managers = get_tree().get_nodes_in_group("round_manager")
	debug_print(str(round_managers.size()) + " round managers")
	if round_managers.size() > 0:
		round_manager = round_managers[0]
		debug_print("Connecting to RoundManager signals")
		
		# Connect signals from round manager
		round_manager.round_started.connect(_on_round_started)
		round_manager.round_ended.connect(_on_round_ended)
		round_manager.level_completed.connect(_on_level_completed)
		round_manager.stage_completed.connect(_on_stage_completed)
		
		# Connect button signal
		start_button.pressed.connect(_on_start_round_button_pressed)
		
		# Update UI with initial values
		update_ui_labels()
	else:
		debug_print("ERROR: No RoundManager found!")

func _on_start_round_button_pressed():
	debug_print("Start Round button pressed!")
	if round_manager and !round_manager.is_round_in_progress():
		debug_print("Calling start_round() on RoundManager")
		round_manager.start_round()
	else:
		debug_print("Cannot start round: round already in progress")

func _on_round_started():
	start_button.disabled = true
	update_ui_labels()
	
	# Update state label
	var is_boss = round_manager.is_current_boss_round()
	if is_boss:
		state_label.text = "BOSS BATTLE!"
		state_label.modulate = Color(1.0, 0.3, 0.3)  # Red for boss
	else:
		state_label.text = "Round In Progress"
		state_label.modulate = Color(1.0, 1.0, 0.5)  # Yellow for regular round

func _on_round_ended():
	update_ui_labels()
	start_button.disabled = false
	state_label.text = "Round Complete"
	state_label.modulate = Color(0.5, 1.0, 0.5)  # Green for completed
	
	# Update button text
	start_button.text = "Start Next Round"

func _on_level_completed():
	update_ui_labels()
	state_label.text = "Level Complete!"
	state_label.modulate = Color(0.5, 0.8, 1.0)  # Blue for level complete

func _on_stage_completed():
	update_ui_labels()
	state_label.text = "Stage Complete!"
	state_label.modulate = Color(1.0, 0.5, 1.0)  # Purple for stage complete

func update_ui_labels():
	if round_manager:
		stage_label.text = "Stage: " + str(round_manager.get_current_stage())
		level_label.text = "Level: " + str(round_manager.get_current_level())
		round_label.text = "Round: " + str(round_manager.get_current_round())
		
		# Update button text based on round status
		if round_manager.is_round_in_progress():
			start_button.text = "Round In Progress"
		else:
			start_button.text = "Start Round"

func debug_print(message):
	if debug_mode:
		print("[RoundUI] " + message)
