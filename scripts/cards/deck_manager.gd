extends Node
class_name DeckManager

signal card_drawn(card)
signal hand_updated(hand)
signal deck_shuffled
signal discard_updated(discard_pile)
signal energy_updated(current, max_energy)

# Deck management
var deck = []  # Cards still in the deck
var hand = []  # Cards in hand
var discard_pile = []  # Cards in the discard pile
var energy = 3  # Starting energy
var max_energy = 3  # Maximum energy
var draw_amount = 5  # Number of cards to draw at the start of a turn

# Card database (will be loaded from a resource file in practice)
var card_database = {}

func _ready():
    # In a real implementation, you'd load cards from a resource or JSON file
    pass

# Initialize a new deck with starter cards for the given character
func initialize_deck(character_id):
    print("Initializing deck for character: ", character_id)
    deck.clear()
    hand.clear()
    discard_pile.clear()
    
    # Reset energy
    energy = max_energy
    emit_signal("energy_updated", energy, max_energy)
    
    # Create starter deck based on character
    var starter_cards = get_starter_cards(character_id)
    print("Starter cards: ", starter_cards)
    
    # Try to get card database node
    var card_db = get_node_or_null("/root/Main/run_manager/CardDatabase")
    
    for card_id in starter_cards:
        var card
        
        # Try to get card from database if available
        if card_db and card_db.cards.has(card_id):
            print("Using card from database: ", card_id)
            card = card_db.get_card(card_id)
        else:
            # Fallback to creating a basic card
            print("Creating basic card: ", card_id)
            card = Card.new()
            card.id = card_id
            card.card_name = card_id.capitalize().replace("_", " ")
            card.description = "A " + card_id.replace("_", " ") + " card."
            card.energy_cost = 1
            
            # Determine card type from name
            if "tower" in card_id:
                card.card_type = "tower"
            elif "trap" in card_id:
                card.card_type = "trap"
            else:
                card.card_type = "power"
        
        deck.append(card)
    
    print("Created deck with " + str(deck.size()) + " cards")
    
    # Shuffle the deck
    shuffle_deck()
    
    # Draw initial hand
    var cards_drawn = draw_cards(draw_amount)
    print("Drew " + str(cards_drawn) + " initial cards")

# Get starter cards for a character
func get_starter_cards(character_id):
    # This would normally be loaded from a character data file
    match character_id:
        "pyromancer":
            return ["fire_blast", "fire_blast", "burning_ground", "burning_ground", 
                   "ember_shot", "ember_shot", "fireball_tower", "fireball_tower", 
                   "flamethrower_tower", "flamethrower_tower", "fire_trap", "fire_trap"]
        "cryomancer":
            return ["frost_nova", "frost_nova", "ice_wall", "ice_wall", 
                   "cold_snap", "cold_snap", "ice_spike_tower", "ice_spike_tower",
                   "frostbite_tower", "frostbite_tower", "freeze_trap", "freeze_trap"]
        "technomancer":
            return ["over_charge", "over_charge", "force_field", "force_field", 
                   "targeting_drone", "targeting_drone", "tesla_tower", "tesla_tower",
                   "drone_tower", "drone_tower", "emp_trap", "emp_trap"]
        _:
            print("Unknown character ID: ", character_id)
            return []

# Shuffle the deck
func shuffle_deck():
    if deck.size() > 0:
        deck.shuffle()
        emit_signal("deck_shuffled")
        print("Deck shuffled, new size: ", deck.size())

# Draw specified number of cards
func draw_cards(amount):
    var cards_drawn = 0
    
    for i in range(amount):
        # If deck is empty, shuffle discard pile into deck
        if deck.size() == 0 and discard_pile.size() > 0:
            print("Deck empty, shuffling discard pile")
            deck = discard_pile.duplicate()
            discard_pile.clear()
            shuffle_deck()
            emit_signal("discard_updated", discard_pile)
        
        # Draw a card if possible
        if deck.size() > 0:
            var card = deck.pop_back()
            hand.append(card)
            emit_signal("card_drawn", card)
            cards_drawn += 1
    
    emit_signal("hand_updated", hand)
    print("Drew ", cards_drawn, " cards. Hand size: ", hand.size())
    return cards_drawn

# Play a card from hand
func play_card(card_index):
    if card_index < 0 or card_index >= hand.size():
        print("Invalid card index: ", card_index)
        return false
    
    var card = hand[card_index]
    
    # Check if we have enough energy
    if energy < card.energy_cost:
        print("Not enough energy to play card: ", card.card_name)
        return false
    
    # Play the card effect
    var success = card.play_effect()
    if not success:
        print("Failed to play card effect: ", card.card_name)
        return false
    
    # Deduct energy
    energy -= card.energy_cost
    emit_signal("energy_updated", energy, max_energy)
    
    # Move card from hand to discard
    hand.remove_at(card_index)
    discard_pile.append(card)
    
    emit_signal("hand_updated", hand)
    emit_signal("discard_updated", discard_pile)
    
    print("Played card: ", card.card_name, ". Energy remaining: ", energy)
    return true

# Start a new turn
func start_turn():
    # Refresh energy
    energy = max_energy
    emit_signal("energy_updated", energy, max_energy)
    
    # Draw cards up to draw amount
    var cards_to_draw = draw_amount - hand.size()
    if cards_to_draw > 0:
        draw_cards(cards_to_draw)
    
    print("Started new turn. Energy: ", energy, ", Hand size: ", hand.size())

# End the current turn
func end_turn():
    # Discard hand
    for card in hand:
        discard_pile.append(card)
    
    hand.clear()
    emit_signal("hand_updated", hand)
    emit_signal("discard_updated", discard_pile)
    
    # Start new turn
    start_turn()
    
    print("Ended turn. Discard pile size: ", discard_pile.size())

# Add a card to the deck (e.g., from rewards)
func add_card_to_deck(card):
    deck.append(card)
    shuffle_deck()
    print("Added card to deck: ", card.card_name)

# Get various counts for UI display
func get_deck_count():
    return deck.size()
    
func get_discard_count():
    return discard_pile.size()
    
func get_hand_count():
    return hand.size()