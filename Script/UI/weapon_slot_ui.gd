# weapon_slot_ui.gd
class_name WeaponSlotUI
extends Control

@onready var weapon_icon: TextureRect = $WeaponIcon
@onready var durability_label: Label = $DurabilityLabel

var current_weapon: WeaponData = null

func _ready() -> void:
	if PlayerHandler and PlayerHandler.inventory_data:
		var inv := PlayerHandler.inventory_data
		if not inv.inventory_updated.is_connected(_on_inventory_updated):
			inv.inventory_updated.connect(_on_inventory_updated)
			
	_on_inventory_updated()

## Dipanggil saat slot senjata berubah (equip senjata baru atau senjata hancur)
func _on_inventory_updated() -> void:
	var new_weapon: WeaponData = null
	if PlayerHandler and PlayerHandler.inventory_data:
		new_weapon = PlayerHandler.inventory_data.weapon_slot
		
	_bind_weapon(new_weapon)

func _bind_weapon(weapon: WeaponData) -> void:
	# Putuskan sinyal dari senjata lama agar tidak terjadi kebocoran memori
	if current_weapon and current_weapon.durability_changed.is_connected(_update_durability_display):
		current_weapon.durability_changed.disconnect(_update_durability_display)
		
	current_weapon = weapon
	
	if current_weapon:
		# Hubungkan sinyal durability dari senjata aktif
		if not current_weapon.durability_changed.is_connected(_update_durability_display):
			current_weapon.durability_changed.connect(_update_durability_display)
			
		weapon_icon.texture = current_weapon.icon
		weapon_icon.visible = current_weapon.icon != null
		durability_label.visible = true
		_update_durability_display(current_weapon.current_durability, current_weapon.max_durability)
	else:
		# Kondisi tangan kosong / senjata baru saja hancur
		weapon_icon.texture = null
		weapon_icon.visible = false
		durability_label.text = "- / -"

func _update_durability_display(current: int, max_val: int) -> void:
	durability_label.text = "%d / %d" % [current, max_val]
