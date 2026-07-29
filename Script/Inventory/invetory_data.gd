# inventory_data.gd (Resource atau Node Manager)
class_name InventoryData
extends Resource

signal inventory_updated(inventory_data: InventoryData)

@export var slots: Array[SlotData]

func add_item(item: ItemData, quantity: int = 1) -> bool:
	# 1. Cek apakah item bisa di-stack dan sudah ada di slot yang belum penuh
	if item.is_stackable:
		for slot in slots:
			if slot and slot.item_data == item and slot.quantity < item.max_stack_size:
				slot.quantity += quantity
				inventory_updated.emit(self)
				return true

	# 2. Jika tidak bisa di-stack/slot lama penuh, cari slot kosong pertama
	for i in range(slots.size()):
		if slots[i] == null:
			var new_slot = SlotData.new()
			new_slot.item_data = item
			new_slot.quantity = quantity
			slots[i] = new_slot
			inventory_updated.emit(self)
			return true

	return false # Inventory Penuh
