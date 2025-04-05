extends Control
class_name CardUI

# Card data connection
var card_data: Card

# UI Elements (will be assigned in the scene)
@onready var card_background = $Background
@onready var card_image = $CardImage
@onready var card_name_label = $CardName
@onready var card_description = $Description
@onready var energy_cost_label = $EnergyCost

# Card states
var is_hovered = false
var is_selected = false
var is_dragging = false
var can_be_played = true

# Starting position for animation purposes
var original_position = Vector2()
var start_drag_position = Vector2()

signal card_clicked(card_ui)
signal card_hovered(card_ui)
signal card_unhovered(card_ui)

func _ready():
    # Set up input detection
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    
    # Store original position
    original_position = position

# Initialize with card data
func init(card: Card):
    card_data = card
    
    # Update visual elements
    card_name_label.text = card.card_name
    card_description.text = card.description
    energy_cost_label.text = str(card.energy_cost)
    
    # Set card image if available
    if card.card_image:
        card_image.texture = card.card_image
    
    # Set card background color based on type
    match card.card_type:
        "power":
            card_background.modulate = Color(0.2, 0.6, 1.0)  # Blue
        "tower":
            card_background.modulate = Color(0.8, 0.3, 0.3)  # Red
        "trap":
            card_background.modulate = Color(0.8, 0.8, 0.2)  # Yellow
        _:
            card_background.modulate = Color(0.7, 0.7, 0.7)  # Gray
    
    # Apply any other visual treatments based on card properties
    update_visual_state()

# Handle input events for dragging and clicking
func _gui_input(event):
    if !can_be_played:
        return
        
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                # Start potential drag
                is_dragging = true
                start_drag_position = get_global_mouse_position()
            else:
                # End drag or click
                is_dragging = false
                
                # If didn't move much, consider it a click
                if start_drag_position.distance_to(get_global_mouse_position()) < 10:
                    _on_card_clicked()
                else:
                    # Card was dragged
                    _on_card_played()
                    
                # Reset position if not played
                position = original_position

# Handle dragging motion
func _process(delta):
    if is_dragging:
        position = position + (get_global_mouse_position() - start_drag_position)
        start_drag_position = get_global_mouse_position()

# Update visual state based on hover/select status
func update_visual_state():
    if !can_be_played:
        modulate = Color(0.5, 0.5, 0.5)  # Gray out if can't be played
    else:
        modulate = Color(1, 1, 1)  # Normal
    
    if is_selected:
        # Selected state - move card up
        var target_pos = original_position - Vector2(0, 30)
        position = position.lerp(target_pos, 0.3)
    elif is_hovered:
        # Hover state - slightly move card up
        var target_pos = original_position - Vector2(0, 15)
        position = position.lerp(target_pos, 0.3)
    else:
        # Normal state - return to original position
        position = position.lerp(original_position, 0.3)

# Callback handlers
func _on_mouse_entered():
    is_hovered = true
    emit_signal("card_hovered", self)

func _on_mouse_exited():
    is_hovered = false
    emit_signal("card_unhovered", self)

func _on_card_clicked():
    is_selected = !is_selected
    emit_signal("card_clicked", self)

func _on_card_played():
    # This would actually play the card and remove it from hand
    print("Attempting to play card: ", card_data.card_name)
    # Logic for playing will be handled by the hand manager
    emit_signal("card_clicked", self)

# Set whether this card can be played (based on energy)
func set_playable(playable: bool):
    can_be_played = playable
    update_visual_state()