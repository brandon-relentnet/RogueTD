extends Control

signal character_selected(character_id)
signal back_pressed

# Character data - in a larger game, this would come from a resource or JSON file
var characters = {
	"pyromancer": {
		"name": "Pyromancer",
		"description": "Fire-based towers with high damage",
		"towers": ["FireballTower", "FlamethrowerTower", "MeteorTower", "InfernoTower", "PhoenixTower"],
		"starter_deck": ["FireBlast", "BurningGround", "EmberShot"]
	},
	"cryomancer": {
		"name": "Cryomancer",
		"description": "Ice-based towers with slowing effects",
		"towers": ["IceSpikeTower", "FrostbiteTower", "BlizzardTower", "GlacierTower", "SnowstormTower"],
		"starter_deck": ["FrostNova", "IceWall", "ColdSnap"]
	},
	"technomancer": {
		"name": "Technomancer",
		"description": "Tech towers with area effects",
		"towers": ["TeslaTower", "DroneTower", "LaserTower", "ShieldTower", "EMPTower"],
		"starter_deck": ["OverCharge", "ForceField", "TargetingDrone"]
	}
}

func _ready():
	# Connect buttons
	$MarginContainer/VBoxContainer/CharacterContainer/Character1/SelectButton.pressed.connect(_on_pyromancer_selected)
	$MarginContainer/VBoxContainer/CharacterContainer/Character2/SelectButton.pressed.connect(_on_cryomancer_selected)
	$MarginContainer/VBoxContainer/CharacterContainer/Character3/SelectButton.pressed.connect(_on_technomancer_selected)
	$MarginContainer/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	
	# In a full implementation, you'd load character portraits here
	# For example:
	# $MarginContainer/VBoxContainer/CharacterContainer/Character1/Portrait.texture = preload("res://assets/images/characters/pyromancer.png")

func _on_pyromancer_selected():
	emit_signal("character_selected", "pyromancer")

func _on_cryomancer_selected():
	emit_signal("character_selected", "cryomancer")

func _on_technomancer_selected():
	emit_signal("character_selected", "technomancer")

func _on_back_pressed():
	emit_signal("back_pressed")

func get_character_data(character_id):
	return characters[character_id]
