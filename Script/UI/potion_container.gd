class_name PotionContainer
extends HBoxContainer

@export var potion_ui_scene: PackedScene

# Properti inventory menggunakan setter agar otomatis mendengarkan sinyal update
var inventory: InventoryData : set = _set_inventory

func _ready() -> void:
	# Daftarkan referensi ke PlayerHandler jika diperlukan
	if "PlayerHandler" in self or ClassDB.class_exists("PlayerHandler"):
		PlayerHandler._potionContainer = self

func _set_inventory(value: InventoryData) -> void:
	inventory = value
	if inventory:
		# Sambungkan sinyal inventory_updated agar UI merespons penggunaan/penambahan potion
		if not inventory.inventory_updated.is_connected(update_potions_ui):
			inventory.inventory_updated.connect(update_potions_ui)
		update_potions_ui()

## Fungsi utama untuk memuat ulang seluruh node UI Potion di dalam Container
func update_potions_ui() -> void:
	if not potion_ui_scene:
		push_error("PotionContainer: potion_ui_scene belum di-assign di Inspector!")
		return
		
	# 1. Bersihkan anak (child) UI lama agar tidak menumpuk
	for child in get_children():
		child.queue_free()
		
	if not inventory:
		return
		
	# 2. Iterasi setiap slot potion yang ada di InventoryData
	for slot in inventory.potion_slots:
		if slot and slot.item_data and slot.item_data is PotionData:
			var potion_ui = potion_ui_scene.instantiate() as PotionUI
			if potion_ui:
				add_child(potion_ui)
				# Inject data ke instance UI (Bukan ke PackedScene)
				potion_ui.potion = slot.item_data as PotionData