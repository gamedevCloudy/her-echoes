extends RayCast3D

@onready var prompt = $Prompt
var current_interactable: Interactable = null

func _physics_process(delta: float) -> void:
	prompt.text = ""
	current_interactable = null
	
	if is_colliding(): 
		var collider = get_collider()
		print("Ray hit: ", collider, " | Type: ", collider.get_class() if collider else "null")
		
		if collider is Interactable: 
			current_interactable = collider
			prompt.text = collider.prompt_message
			print("Found interactable: ", collider.prompt_message)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_interactable:
		if current_interactable is Item:
			var item = current_interactable as Item
			var player = get_owner()
			if player.has_method("add_item_to_inventory"):
				# Connect signal only if not already connected
				if not item.item_picked_up.is_connected(player.add_item_to_inventory):
					item.item_picked_up.connect(player.add_item_to_inventory)
				item.interact()
		elif current_interactable.has_method("interact"):
			current_interactable.interact()
		
