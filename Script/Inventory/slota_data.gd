# slot_data.gd (Resource)
class_name SlotData
extends Resource

@export var item_data: ItemData
@export var quantity: int = 1:
	set(value):
		quantity = value
		if quantity > 1 and not item_data.is_stackable:
			quantity = 1 # Mencegah item non-stackable bertumpuk
