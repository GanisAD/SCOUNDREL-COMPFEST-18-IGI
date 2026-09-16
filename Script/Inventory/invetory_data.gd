class_name InventoryData
extends Resource

## Memancarkan sinyal tiap kali ada perubahan data (Equip, Loot, Pakai Potion)
signal inventory_updated

@export_group("Weapon Slot")
## Slot khusus untuk memegang 1 Senjata aktif
@export var weapon_slot: WeaponData

@export_group("Potion Slots")
## Jumlah maksimum slot potion yang bisa dibawa player
@export var max_potion_slots: int = 3
## Array berukuran tetap untuk slot potion
@export var potion_slots: Array[SlotData] = []


func _init() -> void:
	# Memastikan array potion selalu memiliki ukuran sesuai max_potion_slots
	if potion_slots.size() != max_potion_slots:
		potion_slots.resize(max_potion_slots)


# ==============================================================================
# 1. MANAJEMEN SENJATA (WEAPON)
# ==============================================================================

## Memasang senjata baru ke weapon_slot.
## Mengembalikan WeaponData lama jika ada (bermanfaat untuk mekanisme swap/tukar senjata).
func equip_weapon(new_weapon: WeaponData) -> WeaponData:
	var old_weapon: WeaponData = weapon_slot
	weapon_slot = new_weapon
	
	inventory_updated.emit()
	print("Inventory: Senjata dipasang -> ", new_weapon.name if new_weapon else "Kosong")
	return old_weapon

## Melepas senjata yang sedang dipasang saat ini
func unequip_weapon() -> WeaponData:
	var removed_weapon: WeaponData = weapon_slot
	weapon_slot = null
	
	inventory_updated.emit()
	return removed_weapon


# ==============================================================================
# 2. MANAJEMEN POTION
# ==============================================================================

## Menambahkan potion ke dalam slot potion yang tersedia
func add_potion(potion_item: ItemData, quantity: int = 1) -> bool:
	if not potion_item:
		return false
		
	# A. Cek Stacking terlebih dahulu (jika potion bisa di-stack)
	if potion_item.is_stackable:
		for slot in potion_slots:
			if slot and slot.item_data == potion_item and slot.quantity < potion_item.max_stack_size:
				slot.quantity += quantity
				inventory_updated.emit()
				print("Inventory: Potion di-stack di slot yang ada.")
				return true

	# B. Cari slot kosong pertama
	for i in range(potion_slots.size()):
		if potion_slots[i] == null or potion_slots[i].item_data == null:
			if potion_slots[i] == null:
				potion_slots[i] = SlotData.new()
				
			potion_slots[i].item_data = potion_item
			potion_slots[i].quantity = quantity
			inventory_updated.emit()
			print("Inventory: Potion dimasukkan ke slot indeks ke-", i)
			return true

	print("Inventory: Slot Potion penuh!")
	return false

## Mengonsumsi / Menggunakan potion pada indeks slot tertentu (misal: indeks 0, 1, atau 2)
func use_potion(slot_index: int) -> ItemData:
	if slot_index < 0 or slot_index >= potion_slots.size():
		push_error("Inventory Error: Indeks slot potion di luar jangkauan!")
		return null
		
	var slot: SlotData = potion_slots[slot_index]
	if slot == null or slot.item_data == null:
		print("Inventory: Slot potion kosong.")
		return null
		
	var used_item: ItemData = slot.item_data
	slot.quantity -= 1
	
	# Jika kuantitas habis, kosongkan slot
	if slot.quantity <= 0:
		potion_slots[slot_index] = null
		
	inventory_updated.emit()
	print("Inventory: Potion digunakan -> ", used_item.name)
	return used_item


# ==============================================================================
# 3. ROUTER ITEM GENERIK (Looting / Hadiah Room)
# ==============================================================================

## Fungsi pintu masuk utama saat player mendapat hadiah/loot item.
## Otomatis mengarahkan ke slot Senjata atau slot Potion sesuai tipe data item-nya.
func add_item(item: ItemData, quantity: int = 1) -> bool:
	if not item:
		return false
		
	if item is WeaponData:
		equip_weapon(item as WeaponData)
		return true
	else:
		return add_potion(item, quantity)
