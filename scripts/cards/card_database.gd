extends Node

# This class serves as a database of all available cards in the game
# In a more robust implementation, this would likely load from JSON or other data files

# Dictionary of all cards in the game, accessible by ID
var cards = {}

func _ready():
    # Initialize all cards
    _initialize_power_cards()
    _initialize_tower_cards()
    _initialize_trap_cards()
    
    print("Card database initialized with ", cards.size(), " cards")

# Get a card by ID
func get_card(card_id: String) -> Card:
    if not cards.has(card_id):
        push_error("Card ID not found in database: " + card_id)
        return null
        
    return cards[card_id]

# Create and register a basic card
func _create_basic_card(
    id: String,
    name: String,
    description: String,
    energy_cost: int,
    card_type: String,
    effect_type: int,
    effect_value: int = 0,
    effect_duration: int = 1
) -> Card:
    var card = Card.new()
    card.id = id
    card.card_name = name
    card.description = description
    card.energy_cost = energy_cost
    card.card_type = card_type
    card.effect_type = effect_type
    card.effect_value = effect_value
    card.effect_duration = effect_duration
    
    # In a complete implementation, you'd also set the card image here:
    # card.card_image = preload("res://assets/images/cards/" + id + ".png")
    
    # Register the card in our database
    cards[id] = card
    return card

# Initialize all power cards
func _initialize_power_cards():
    # Pyromancer cards
    _create_basic_card(
        "fire_blast",
        "Fire Blast",
        "Deal 3 damage to an enemy.",
        1,
        "power",
        Card.EffectType.DAMAGE,
        3
    )
    
    _create_basic_card(
        "burning_ground",
        "Burning Ground",
        "Create a patch of burning ground that damages enemies for 2 turns.",
        2,
        "power",
        Card.EffectType.TRAP,
        2,
        2
    )
    
    _create_basic_card(
        "ember_shot",
        "Ember Shot",
        "Deal 1 damage and apply a burning effect for 2 turns.",
        1,
        "power",
        Card.EffectType.DEBUFF,
        1,
        2
    )
    
    # Cryomancer cards
    _create_basic_card(
        "frost_nova",
        "Frost Nova",
        "Slow all enemies on the field by 30% for 2 turns.",
        2,
        "power",
        Card.EffectType.DEBUFF,
        30,
        2
    )
    
    _create_basic_card(
        "ice_wall",
        "Ice Wall",
        "Create a wall that blocks enemies for 1 turn.",
        2,
        "power",
        Card.EffectType.TRAP,
        0,
        1
    )
    
    _create_basic_card(
        "cold_snap",
        "Cold Snap",
        "Freeze an enemy in place for 1 turn.",
        1,
        "power",
        Card.EffectType.DEBUFF,
        100,
        1
    )
    
    # Technomancer cards
    _create_basic_card(
        "over_charge",
        "Overcharge",
        "Double a tower's attack speed for 1 turn.",
        2,
        "power",
        Card.EffectType.BUFF,
        100,
        1
    )
    
    _create_basic_card(
        "force_field",
        "Force Field",
        "Create a barrier that blocks 5 damage per enemy.",
        2,
        "power",
        Card.EffectType.SPECIAL,
        5,
        1
    )
    
    _create_basic_card(
        "targeting_drone",
        "Targeting Drone",
        "Your towers deal 25% more damage to the targeted enemy.",
        1,
        "power",
        Card.EffectType.DEBUFF,
        25,
        2
    )

# Initialize all tower cards
func _initialize_tower_cards():
    # Pyromancer towers
    _create_basic_card(
        "fireball_tower",
        "Fireball Tower",
        "Summon a tower that shoots fireballs at enemies.",
        2,
        "tower",
        Card.EffectType.SUMMON_TOWER,
        4
    )
    
    _create_basic_card(
        "flamethrower_tower",
        "Flamethrower Tower",
        "Summon a tower that spews flames in a cone, damaging all enemies in range.",
        3,
        "tower",
        Card.EffectType.SUMMON_TOWER,
        3
    )
    
    # Cryomancer towers
    _create_basic_card(
        "ice_spike_tower",
        "Ice Spike Tower",
        "Summon a tower that shoots ice spikes, slowing enemies by 20%.",
        2,
        "tower",
        Card.EffectType.SUMMON_TOWER,
        3
    )
    
    _create_basic_card(
        "frostbite_tower",
        "Frostbite Tower",
        "Summon a tower that gradually freezes enemies, slowing them more over time.",
        3,
        "tower",
        Card.EffectType.SUMMON_TOWER,
        2
    )
    
    # Technomancer towers
    _create_basic_card(
        "tesla_tower",
        "Tesla Tower",
        "Summon a tower that shoots lightning, chaining between up to 3 enemies.",
        2,
        "tower",
        Card.EffectType.SUMMON_TOWER,
        3
    )
    
    _create_basic_card(
        "drone_tower",
        "Drone Tower",
        "Summon a tower that deploys small drones to attack enemies.",
        3,
        "tower",
        Card.EffectType.SUMMON_TOWER,
        5
    )

# Initialize all trap cards
func _initialize_trap_cards():
    # General traps
    _create_basic_card(
        "fire_trap",
        "Fire Trap",
        "Place a trap that explodes when enemies walk over it, dealing 5 damage.",
        1,
        "trap",
        Card.EffectType.TRAP,
        5
    )
    
    _create_basic_card(
        "freeze_trap",
        "Freeze Trap",
        "Place a trap that freezes enemies in place for 2 seconds.",
        1,
        "trap",
        Card.EffectType.TRAP,
        2
    )
    
    _create_basic_card(
        "emp_trap",
        "EMP Trap",
        "Place a trap that stuns mechanical enemies for 3 seconds.",
        1,
        "trap",
        Card.EffectType.TRAP,
        3
    )