class_name DebuffContainer
extends HBoxContainer

@export var debuff_ui_scene: PackedScene

# Properti inventory menggunakan setter agar otomatis mendengarkan sinyal update
var inventory: InventoryData : set = _set_inventory

func _ready() -> void:
	var ph = get_node_or_null("/root/PlayerHandler")
	if ph:
		if not inventory and "inventory_data" in ph and ph.inventory_data:
			inventory = ph.inventory_data
	else:
		update_debuffs_ui()

func _set_inventory(value: InventoryData) -> void:
	if inventory and inventory.inventory_updated.is_connected(update_debuffs_ui):
		inventory.inventory_updated.disconnect(update_debuffs_ui)
	inventory = value
	if inventory:
		if not inventory.inventory_updated.is_connected(update_debuffs_ui):
			inventory.inventory_updated.connect(update_debuffs_ui)
		update_debuffs_ui()

## Fungsi utama untuk memuat ulang seluruh node UI Debuff di dalam Container
func update_debuffs_ui() -> void:
	if not debuff_ui_scene:
		debuff_ui_scene = load("res://Scene/Components/Item/debuff.tscn")
		if not debuff_ui_scene:
			push_error("DebuffContainer: debuff_ui_scene belum di-assign di Inspector!")
			return
		
	# 1. Bersihkan anak (child) UI lama agar tidak menumpuk
	for child in get_children():
		remove_child(child)
		child.queue_free()
		
	if not inventory:
		return
		
	# 2. Iterasi setiap slot debuff yang ada di InventoryData
	for slot in inventory.debuff_slots:
		if slot and slot.item_data and slot.item_data is DebuffData:
			var debuff_ui = debuff_ui_scene.instantiate() as DebuffUI
			if debuff_ui:
				add_child(debuff_ui)
				debuff_ui.slot_data = slot
