# room_data.gd
class_name RoomData
extends Resource

@export var room_name: String = "Ruangan Tanpa Nama"
@export var room_type: RoomType.Type = RoomType.Type.CLUB
@export var room_icon: Texture2D # Icon visual kartu/symbol (Diamonds/Hearts/Clubs/Spades)
@export_multiline var description: String = ""

@export_group("Loot & Encounter Table")
## Daftar/Pool Item yang BISA muncul di ruangan ini.
## Bisa diisi Resource Item, Card, Potion, dll.
@export var possible_item_pool: Array[Resource] = []

## Daftar/Pool Encounter Musuh (Khusus untuk tipe CLUB)
@export var possible_monster_encounters: Array[Resource] = []

@export_group("Room Config")
## Kemungkinan/bobot munculnya item opsional
@export_range(0.0, 1.0) var drop_chance: float = 1.0
