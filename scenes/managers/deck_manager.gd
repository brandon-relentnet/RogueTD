extends Node
class_name DeckManager

@export var hand_size: int = 5

# These arrays hold your card data.
var deck: Array = []
var draw_pile: Array = []
var discard_pile: Array = []
var hand: Array = []

func _ready():
	# Populate the deck with 15 gold-card.pngs.
	# Each card is represented as a dictionary with a name and icon.
	for i in range(15):
		deck.append({"name": "Gold Card", "icon": load("res://assets/cards/gold-card.png")})
	
	# Initialize the draw pile with the full deck and shuffle it.
	draw_pile = deck.duplicate()
	shuffle_draw_pile()
	
	# Optionally, draw an initial hand.
	draw_hand()

func shuffle_draw_pile():
	draw_pile.shuffle()

# Call this function at the start of each level.
func start_level():
	discard_hand()
	draw_hand()
	# (Optional) Update your UI with the new hand here.

func discard_hand():
	# Move all cards from the current hand to the discard pile.
	for card in hand:
		discard_pile.append(card)
	hand.clear()

func draw_hand():
	for i in range(hand_size):
		# If the draw pile is empty, reshuffle the discard pile into it.
		if draw_pile.is_empty():
			reshuffle_discard_into_draw()
		# Draw a card if available.
		if not draw_pile.is_empty():
			hand.append(draw_pile.pop_front())
		else:
			break

	# Debug print: output the names of the drawn cards.
	for card in hand:
		print("Drew card: ", card["name"])

func reshuffle_discard_into_draw():
	if discard_pile.is_empty():
		return
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	shuffle_draw_pile()
