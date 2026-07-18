class_name Card
extends Resource

# Mendefinisikan tipe kartu dasar ala Slay the Spire
enum Type {ATTACK, SKILL, POWER}

# Mendefinisikan target kartu untuk menentukan State UI (Aiming atau Dragging biasa)
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}

@export_group("Informasi Dasar")
@export var id: String = "card_base"
@export var name: String = "Nama Kartu"
@export_multiline var description: String = "Deskripsi efek kartu."
@export var icon: Texture2D

@export_group("Mekanik Kartu")
@export var type: Type = Type.ATTACK
@export var target: Target = Target.SINGLE_ENEMY
@export var cost: int = 1
@export var exhaust: bool = false

# ==========================================
# FUNGSI UTILITAS & VALIDASI
# ==========================================

## Fungsi ini krusial untuk dipanggil oleh Card UI State Machine 
## guna menentukan apakah pemain perlu menarik garis panah ke arah musuh.
func is_single_targeted() -> bool:
	return target == Target.SINGLE_ENEMY

## Fungsi virtual yang nantinya akan di-override oleh kartu spesifik
## atau ditangani oleh sistem efek (Effect Handler) saat kartu dilepaskan.
func apply_effects(_targets: Array[Node], _player: Node) -> void:
	# Logika spesifik kartu (seperti memberikan damage atau draw kartu)
	# akan dieksekusi di sini nantinya.
	pass
	
