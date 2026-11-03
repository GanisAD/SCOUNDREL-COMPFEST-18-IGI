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

@export_group("Debuff Slots")
## Jumlah maksimum slot debuff yang bisa aktif di player
@export var max_debuff_slots: int = 3
## Array berukuran tetap untuk slot debuff (masing-masing berupa SlotData)
@export var debuff_slots: Array[SlotData] = []


func _init() -> void:
	# Memastikan array potion selalu memiliki ukuran sesuai max_potion_slots
	if potion_slots.size() != max_potion_slots:
		potion_slots.resize(max_potion_slots)
	# Memastikan array debuff selalu memiliki ukuran sesuai max_debuff_slots
	if debuff_slots.size() != max_debuff_slots:
		debuff_slots.resize(max_debuff_slots)


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
# 3. MANAJEMEN DEBUFF
# ==============================================================================

## Menambahkan debuff ke dalam slot debuff yang tersedia
func add_debuff(debuff_item: DebuffData, duration: int = -1) -> bool:
	if not debuff_item:
		return false
		
	var battle_duration: int = duration if duration > 0 else debuff_item.duration_in_battles
	
	# A. Cek Stacking / Refresh durasi jika debuff sejenis sudah ada di slot
	for slot in debuff_slots:
		if slot and slot.item_data == debuff_item:
			slot.quantity += battle_duration
			inventory_updated.emit()
			print("Inventory: Debuff '%s' durasi ditambah menjadi %d battle." % [debuff_item.name, slot.quantity])
			return true
	
	# B. Cari slot debuff kosong pertama
	for i in range(debuff_slots.size()):
		if debuff_slots[i] == null or debuff_slots[i].item_data == null:
			if debuff_slots[i] == null:
				debuff_slots[i] = SlotData.new()
			debuff_slots[i].item_data = debuff_item
			debuff_slots[i].quantity = battle_duration
			inventory_updated.emit()
			print("Inventory: Debuff '%s' dimasukkan ke slot debuff indeks ke-%d dengan durasi %d battle." % [debuff_item.name, i, battle_duration])
			return true
			
	print("Inventory: Slot Debuff penuh!")
	return false

## Menghapus debuff dari slot tertentu
func remove_debuff(slot_index: int) -> DebuffData:
	if slot_index < 0 or slot_index >= debuff_slots.size():
		return null
	var slot: SlotData = debuff_slots[slot_index]
	if slot == null or slot.item_data == null:
		return null
	var removed: DebuffData = slot.item_data as DebuffData
	debuff_slots[slot_index] = null
	inventory_updated.emit()
	print("Inventory: Debuff '%s' dilepas dari slot %d." % [removed.name if removed else "Unknown", slot_index])
	return removed

## Mengurangi sisa durasi pertempuran untuk seluruh debuff aktif setelah 1 pertempuran selesai
func decrement_debuff_battles() -> void:
	var changed: bool = false
	for i in range(debuff_slots.size()):
		var slot: SlotData = debuff_slots[i]
		if slot and slot.item_data and slot.item_data is DebuffData:
			slot.quantity -= 1
			changed = true
			print("Inventory: Debuff '%s' sisa durasi: %d pertempuran." % [slot.item_data.name, slot.quantity])
			if slot.quantity <= 0:
				print("Inventory: Debuff '%s' telah kedaluwarsa dan dihapus!" % slot.item_data.name)
				debuff_slots[i] = null
	if changed:
		inventory_updated.emit()

## Mengembalikan semua DebuffData yang sedang aktif
func get_active_debuffs() -> Array[DebuffData]:
	var result: Array[DebuffData] = []
	for slot in debuff_slots:
		if slot and slot.item_data and slot.item_data is DebuffData:
			result.append(slot.item_data as DebuffData)
	return result


# ==============================================================================
# 4. ROUTER ITEM GENERIK (Looting / Hadiah Room)
# ==============================================================================

## Fungsi pintu masuk utama saat player mendapat hadiah/loot item.
## Otomatis mengarahkan ke slot Senjata, Potion, atau Debuff sesuai tipe data item-nya.
func add_item(item: ItemData, quantity: int = 1) -> bool:
	if not item:
		return false
		
	if item is WeaponData:
		equip_weapon(item as WeaponData)
		return true
	elif item is DebuffData:
		return add_debuff(item as DebuffData, quantity if quantity > 1 else -1)
	elif item is PotionData:
		return add_potion(item, quantity)
	else:
		return add_potion(item, quantity)
