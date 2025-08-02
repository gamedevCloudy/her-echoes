extends Interactable
class_name Item

@export var item_name: String = "Item"
@export var is_pickupable: bool = true
signal item_picked_up(item: Item)

func _ready() -> void:
	if is_pickupable:
		prompt_message = "Press E to pick up " + item_name

func interact() -> void:
	if is_pickupable:
		item_picked_up.emit(self)
		queue_free()