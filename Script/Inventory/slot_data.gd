# slot_data.gd (Resource)
class_name SlotData
extends Resource

@export var item_data: ItemData
@export var quantity: int = 1:
	set(value):
		quantity = value
		if quantity > 1 and item_data and not (item_data.is_stackable or item_data is DebuffData):
			quantity = 1 # Mencegah item non-stackable bertumpuk
