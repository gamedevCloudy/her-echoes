extends Interactable
class_name Item

@export var item_name: String = "Item"
@export var is_pickupable: bool = true
signal item_picked_up(item: Item)

func _ready() -> void:
	if is_pickupable:
		prompt_message = "[E] " + item_name

func interact() -> void:
	if is_pickupable:
		item_picked_up.emit(self)
		# Hide the entire parent node (the visual model)
		get_parent().hide()
		# Also disable this collision body so it can't be detected
		set_collision_layer_value(1, false)
		set_collision_mask_value(1, false)