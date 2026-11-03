class_name PotionContainer
extends HBoxContainer

@export var potion_ui_scene: PackedScene

# Properti inventory menggunakan setter agar otomatis mendengarkan sinyal update
var inventory: InventoryData : set = _set_inventory

func _ready() -> void:
	var ph = get_node_or_null("/root/PlayerHandler")
	if ph:
		if "_potionContainer" in ph:
			ph._potionContainer = self
		if not inventory and "inventory_data" in ph and ph.inventory_data:
			inventory = ph.inventory_data
	else:
		update_potions_ui()

func _set_inventory(value: InventoryData) -> void:
	if inventory and inventory.inventory_updated.is_connected(update_potions_ui):
		inventory.inventory_updated.disconnect(update_potions_ui)
	inventory = value
	if inventory:
		if not inventory.inventory_updated.is_connected(update_potions_ui):
			inventory.inventory_updated.connect(update_potions_ui)
		update_potions_ui()

## Fungsi utama untuk memuat ulang seluruh node UI Potion di dalam Container
func update_potions_ui() -> void:
	if not potion_ui_scene:
		potion_ui_scene = load("res://Scene/Components/Item/potion.tscn")
		if not potion_ui_scene:
			push_error("PotionContainer: potion_ui_scene belum di-assign di Inspector!")
			return
		
	# 1. Bersihkan anak (child) UI lama agar tidak menumpuk
	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	if not inventory:
		return
		
	# 2. Iterasi setiap slot potion yang ada di InventoryData
	for i in range(inventory.potion_slots.size()):
		var slot: SlotData = inventory.potion_slots[i]
		if slot and slot.item_data and slot.item_data is PotionData:
			var potion_ui = potion_ui_scene.instantiate() as PotionUI
			if potion_ui:
				add_child(potion_ui)
				potion_ui.slot_index = i
				potion_ui.slot_data = slot
