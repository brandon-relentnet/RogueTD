extends Control
class_name HandManager

# Card UI scene
@export var card_scene: PackedScene

# References to UI elements
@onready var hand_container = $HandContainer
@onready var energy_label = $EnergyPanel/EnergyLabel
@onready var deck_count_label = $DeckPanel/CountLabel
@onready var discard_count_label = $DiscardPanel/CountLabel

# Connection to the deck manager
var deck_manager: DeckManager

# Currently displayed cards
var card_ui_nodes = []

signal card_played(card_index)

func _ready():
	print("Hand Manager initializing")
	
	# We'll connect to the deck manager once it's available
	call_deferred("connect_to_deck_manager")

	 # Connect the end turn button
	var end_turn_button = get_node_or_null("EndTurnButton")
	if end_turn_button:
		end_turn_button.pressed.connect(_on_end_turn_pressed)
	else:
		print("Could not find EndTurnButton node")
	
	# Update UI with initial state
	update_all_counts()

func connect_to_deck_manager():
	print("Attempting to connect to deck manager")
	# Try to find the deck manager
	deck_manager = get_node_or_null("/root/Main/run_manager/DeckManager")
	
	if not deck_manager:
		print("HandManager: Could not find DeckManager node, will retry in 1 second")
		# Retry in 1 second
		await get_tree().create_timer(1.0).timeout
		connect_to_deck_manager()
		return
	
	print("HandManager: Found DeckManager, connecting signals")
	
	# Connect signals from the deck manager
	deck_manager.card_drawn.connect(_on_card_drawn)
	deck_manager.hand_updated.connect(_on_hand_updated)
	deck_manager.deck_shuffled.connect(_on_deck_shuffled)
	deck_manager.discard_updated.connect(_on_discard_updated)
	deck_manager.energy_updated.connect(_on_energy_updated)
	
	# Force an initial update
	if deck_manager.hand.size() > 0:
		print("Initial hand has cards, updating UI")
		_on_hand_updated(deck_manager.hand)
	else:
		print("Initial hand is empty")
	
	# Update UI with initial state
	update_all_counts()

# Update the hand display when the hand is updated
func _on_hand_updated(hand):
	# Clear existing card UI
	clear_hand_ui()
	
	# Create UI for each card in hand
	for i in range(hand.size()):
		var card = hand[i]
		add_card_to_ui(card)
	
	# Set card playability based on energy
	update_card_playability()
	
	# Update card positions in an arc formation
	position_cards_in_line()

# Add a single card to the UI
func add_card_to_ui(card):
	var card_ui = card_scene.instantiate()
	hand_container.add_child(card_ui)
	card_ui.init(card)
	
	# Connect card signals
	card_ui.connect("card_clicked", Callable(self, "_on_card_ui_clicked"))
	
	card_ui_nodes.append(card_ui)
	return card_ui

# Clear all cards from UI
func clear_hand_ui():
	for card_ui in card_ui_nodes:
		card_ui.queue_free()
	
	card_ui_nodes.clear()

# Replace the position_cards_in_arc function with this simplified version
func position_cards_in_line():
	var card_count = card_ui_nodes.size()
	if card_count == 0:
		return

	# Get container dimensions
	var container_width = hand_container.size.x
	var container_height = hand_container.size.y
	
	# Get card size (assuming all cards have the same size)
	if card_ui_nodes[0] == null:
		return
	var card_width = card_ui_nodes[0].size.x
	var card_height = card_ui_nodes[0].size.y
	
	# Calculate spacing between cards
	var total_cards_width = card_width * card_count
	var available_width = container_width
	
	# Determine if we need to overlap cards
	var spacing = 0
	if total_cards_width <= available_width:
		# Enough space to show all cards without overlap
		spacing = (available_width - total_cards_width) / (card_count + 1)
	else:
		# Not enough space, cards will need to overlap
		spacing = (available_width - card_width) / (card_count - 1)
	
	# Position each card in a straight line
	for i in range(card_count):
		var card = card_ui_nodes[i]
		
		if card_count == 1:
			# Center a single card
			card.position = Vector2(
				(container_width - card_width) / 2,
				(container_height - card_height) / 2  # Center vertically
			)
		else:
			if total_cards_width <= available_width:
				# Position with equal spacing between cards
				card.position = Vector2(
					spacing * (i + 1) + card_width * i,
					(container_height - card_height) / 2  # Center vertically
				)
			else:
				# Position with overlap
				card.position = Vector2(
					i * spacing,
					(container_height - card_height) / 2  # Center vertically
				)
		
		# No rotation needed for straight line
		card.rotation = 0
	
	# Ensure all cards are updated visually
	for card in card_ui_nodes:
		card.update_visual_state()
		
# Update which cards can be played based on available energy
func update_card_playability():
	var current_energy = deck_manager.energy
	
	for i in range(card_ui_nodes.size()):
		var card_ui = card_ui_nodes[i]
		var card = deck_manager.hand[i]
		
		# Card is playable if energy is sufficient
		var playable = current_energy >= card.energy_cost
		card_ui.set_playable(playable)

# Handle clicks on card UI elements
func _on_card_ui_clicked(card_ui):
	var card_index = card_ui_nodes.find(card_ui)
	if card_index == -1:
		return
	
	# Check if card can be played
	var card = deck_manager.hand[card_index]
	if deck_manager.energy < card.energy_cost:
		print("Not enough energy to play this card")
		return
	
	# Emit signal that card was played
	emit_signal("card_played", card_index)
	
	# Play the card via deck manager
	deck_manager.play_card(card_index)

# Update UI when a card is drawn
func _on_card_drawn(card):
	update_deck_count()

# Update UI when deck is shuffled
func _on_deck_shuffled():
	update_deck_count()

# Update UI when discard pile changes
func _on_discard_updated(discard_pile):
	update_discard_count()

# Update UI when energy changes
func _on_energy_updated(current, max_energy):
	update_energy_display()
	update_card_playability()

# Update all UI counts
func update_all_counts():
	update_deck_count()
	update_discard_count()
	update_energy_display()

# Update deck count display
func update_deck_count():
	if deck_manager:
		deck_count_label.text = str(deck_manager.get_deck_count())

# Update discard count display
func update_discard_count():
	if deck_manager:
		discard_count_label.text = str(deck_manager.get_discard_count())

# Update energy display
func update_energy_display():
	if deck_manager:
		energy_label.text = str(deck_manager.energy) + "/" + str(deck_manager.max_energy)

# Handle window resize
func _notification(what):
	if what == NOTIFICATION_RESIZED:
		position_cards_in_line()

func _on_end_turn_pressed():
	print("End turn button pressed")
	if deck_manager:
		deck_manager.end_turn()
	else:
		print("Cannot end turn - deck manager not found")
