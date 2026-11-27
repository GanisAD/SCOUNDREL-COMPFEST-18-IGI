# weapon_data.gd
class_name WeaponData
extends ItemData  # Atau extends Resource jika belum ada kelas dasar ItemData

signal durability_changed(current: int, max_val: int)

@export_group("Weapon Properties")
@export var weapon_type: String = "Sword"
@export var base_damage_bonus: int = 0

@export_group("Weapon Audio")
@export var attack_sfx: AudioStream

@export_group("Card Deck")
# Mengunci/menyimpan deck kartu eksklusif milik senjata ini
@export var weapon_deck: CardPile

@export_group("Durability Settings")
@export var max_durability: int = 3

var current_durability: int = 0 : set = _set_current_durability

func _set_current_durability(value: int) -> void:
	current_durability = clampi(value, 0, max_durability)
	durability_changed.emit(current_durability, max_durability)

## Menambah keausan senjata. Mengembalikan true jika senjata sudah mencapai batas maksimal (rusak).
func increment_durability(amount: int = 1) -> bool:
	self.current_durability += amount
	return current_durability >= max_durability
