extends Interactable
class_name TowerInteraction

@export var required_items: Array[String] = ["Anchor", "Rope"]
var has_been_used: bool = false

func _ready() -> void:
	prompt_message = "[E] Climb Tower (Need Anchor & Rope)"
	print("Tower interaction ready at position: ", global_position)

func _physics_process(_delta: float) -> void:
	if has_been_used:
		return
		
	# Update prompt based on player inventory
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("has_item"):
		var has_all_items = true
		var missing_items = []
		
		for item in required_items:
			if not player.has_item(item):
				has_all_items = false
				missing_items.append(item)
		
		if has_all_items:
			prompt_message = "[E] Press E"
		else:
			prompt_message = "[E] Need: " + str(missing_items)

func interact() -> void:
	if has_been_used:
		return
	
	print("=== TOWER INTERACTION TRIGGERED ===")
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_tree().get_nodes_in_group("player")[0] if get_tree().get_nodes_in_group("player").size() > 0 else null
	
	if not player:
		# Find player by searching for Player node
		player = get_tree().current_scene.get_node("Player")
	
	print("Player found: ", player)
	print("Player inventory: ", player.get_inventory() if player else "No player")
	
	if player and player.has_method("has_item"):
		var has_all_items = true
		var missing_items = []
		
		for item in required_items:
			if not player.has_item(item):
				has_all_items = false
				missing_items.append(item)
		
		print("Has all items: ", has_all_items)
		print("Missing: ", missing_items)
		
		if has_all_items:
			has_been_used = true
			end_game()
	else:
		print("Player not found or doesn't have inventory system")

func end_game() -> void:
	print("Game Complete! Starting train ending sequence...")
	
	# Create train ending sequence
	var train_ending = preload("res://train_ending.gd").new()
	get_tree().current_scene.add_child(train_ending)
	train_ending.start_train_ending()