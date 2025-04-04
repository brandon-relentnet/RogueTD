extends Button

# Tower Button for Shop UI

@onready var icon_texture = $VBoxContainer/Icon
@onready var name_label = $VBoxContainer/NameLabel
@onready var cost_label = $VBoxContainer/CostLabel
# @onready var description_label = $VBoxContainer/DescriptionLabel

var tower_data = {}

func _ready():
	# Ensure UI elements are correctly referenced
	assert(icon_texture != null, "Icon node not found")
	assert(name_label != null, "NameLabel node not found")
	assert(cost_label != null, "CostLabel node not found")
	# assert(description_label != null, "DescriptionLabel node not found")

func set_tower_data(data):
	tower_data = data
	
	# Update UI elements with tower data
	if tower_data.has("icon") and tower_data.icon != null:
		icon_texture.texture = tower_data.icon
	
	name_label.text = tower_data.name
	cost_label.text = str(tower_data.cost) + " Gold"
	# description_label.text = tower_data.description
	
	# Set tooltip
	tooltip_text = tower_data.description
