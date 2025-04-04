extends CanvasLayer

# Tower Shop System

# Tower data - you can expand this with more towers
@export var available_towers = [
	{
		"name": "Mortar Tower",
		"description": "High damage, slow fire rate, area damage",
		"cost": 50,
		"icon": preload("res://assets/towers/mortar/mortar.png"),
		"scene": preload("res://scenes/towers/mortar/mortar.tscn")
	},
	# Add more towers as needed
]

signal tower_selected(tower_data)

# References to UI elements
@onready var shop_container = $ShopContainer
@onready var shop_button = $ShopButton
@onready var tower_grid = $ShopContainer/VBoxContainer/ScrollContainer/TowerGrid
@onready var currency_label = $CurrencyLabel

var is_shop_open = false
var tower_button_scene = preload("res://scenes/shop/towerbutton.tscn") # Create this scene

func _ready():
	# Make sure all UI nodes exist before proceeding
	if !shop_container or !shop_button or !tower_grid or !currency_label:
		print("ERROR: One or more UI nodes not found in TowerShop!")
		print("shop_container: ", shop_container)
		print("shop_button: ", shop_button)
		print("tower_grid: ", tower_grid)
		print("currency_label: ", currency_label)
		return
	
	# Hide shop on start
	shop_container.visible = false
	
	# Connect shop button
	shop_button.pressed.connect(toggle_shop)
	
	# Populate the shop with available towers
	populate_shop()
	
	# Update currency display
	update_currency_display()

func toggle_shop():
	print("Toggle shop called!")
	is_shop_open = !is_shop_open
	print("Shop should now be:", "OPEN" if is_shop_open else "CLOSED")
	shop_container.visible = is_shop_open
	print("Shop container visibility set to:", shop_container.visible)
	
	# Pause the game when shop is open (optional)
	if is_shop_open:
		get_tree().paused = false
	else:
		get_tree().paused = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_S:  # Use 'S' key as a test
			print("S key pressed, toggling shop")
			toggle_shop()

func populate_shop():
	print("Populating shop...")
	# Check if tower_grid exists
	if !tower_grid:
		print("ERROR: tower_grid is null in populate_shop()")
		return
	
	# Clear existing tower buttons
	print("Clearing existing buttons...")
	for child in tower_grid.get_children():
		child.queue_free()
	
	# Add a button for each available tower
	print("Adding tower buttons...")
	for tower_data in available_towers:
		print("Creating button for:", tower_data.name)
		var button = tower_button_scene.instantiate()
		print("Button instantiated")
		tower_grid.add_child(button)
		print("Button added to grid")
		
		# Set button properties
		print("Setting button data...")
		button.set_tower_data(tower_data)
		print("Connecting button signal...")
		button.pressed.connect(_on_tower_button_pressed.bind(tower_data))
		print("Button setup complete")
	
	print("Shop population complete")

func _on_tower_button_pressed(tower_data):
	# Emit signal with selected tower data
	tower_selected.emit(tower_data)
	
	# Close shop after selection
	toggle_shop()

func update_currency_display(amount = 0):
	# Check if currency_label exists
	if !currency_label:
		print("ERROR: currency_label is null in update_currency_display()")
		return
		
	# Update this when player currency changes
	currency_label.text = "Gold: " + str(amount)

# Call this from your game manager when currency changes
func set_currency(amount):
	update_currency_display(amount)
