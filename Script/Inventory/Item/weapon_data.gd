# weapon_data.gd
class_name WeaponData
extends ItemData  # Atau extends Resource jika belum ada kelas dasar ItemData

@export_group("Weapon Properties")
@export var weapon_type: String = "Sword"
@export var base_damage_bonus: int = 0

@export_group("Card Deck")
# Mengunci/menyimpan deck kartu eksklusif milik senjata ini
@export var weapon_deck: CardPile
