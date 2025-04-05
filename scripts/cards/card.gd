extends Resource
class_name Card

# Card basic properties
@export var id: String = ""
@export var card_name: String = "Card"
@export var description: String = "No description"
@export var energy_cost: int = 1
@export var card_type: String = "power"  # "power", "tower", etc.
@export var card_image: Texture2D

# For visual representation
@export var card_color: Color = Color(1, 1, 1, 1)

# Card effect types
enum EffectType {
    DAMAGE,
    BUFF,
    DEBUFF,
    SUMMON_TOWER,
    TRAP,
    HEAL,
    DRAW,
    ENERGY,
    SPECIAL
}

@export var effect_type: EffectType = EffectType.SPECIAL
@export var effect_value: int = 0  # Damage amount, buff percentage, etc.
@export var effect_duration: int = 1  # For temporary effects, in turns/waves

# Method to play the card
# This will be overridden by specific card types
func play_effect(target = null):
    # Basic implementation, to be extended
    print("Playing card: ", card_name)
    return true

# Method to get a dictionary representation of the card
func to_dict():
    return {
        "id": id,
        "name": card_name,
        "description": description,
        "energy_cost": energy_cost,
        "card_type": card_type,
        "effect_type": effect_type,
        "effect_value": effect_value,
        "effect_duration": effect_duration
    }

# Static method to create a card from a dictionary
static func from_dict(data):
    var card = Card.new()
    card.id = data.id
    card.card_name = data.name
    card.description = data.description
    card.energy_cost = data.energy_cost
    card.card_type = data.card_type
    card.effect_type = data.effect_type
    card.effect_value = data.effect_value
    card.effect_duration = data.effect_duration
    return card

# Can this card be played right now?
func can_play(player_energy, game_state):
    return player_energy >= energy_cost