extends Resource
class_name Stats 

# Sinyal global internal untuk memberi tahu UI agar mendesain ulang teks HP/Block secara realtime 
signal stats_changed 

enum BlockResetType {
	RESET_ALL,    # Default: Block kembali ke 0 setiap giliran
	RETAIN_ALL,   # Golem: Block tidak pernah di-reset (terus menumpuk)
	DECAY_HALF    # Opsi masa depan: Block berkurang 50% per giliran
}


@export_group("Visual & Base Config")
@export var max_health: int = 35 
@export var art: Texture2D # Sprite visual karakter

@export_group("Defense Rules")
@export var block_reset_type: BlockResetType = BlockResetType.RESET_ALL

# Menggunakan pola Setter bawaan Godot 4 agar setiap perubahan angka langsung memicu pembaruan UI 
var health: int : set = set_health 
var block: int : set = set_block 
var charge_stacks: int = 0 : set = _set_charge_stacks

func set_health(value: int) -> void:
	health = clamp(value, 0, max_health) 
	stats_changed.emit() # UI akan langsung mendeteksi sinyal ini 

func set_block(value: int) -> void:
	block = max(0, value) 
	stats_changed.emit() 
	
# Fungsi terenkapsulasi untuk dipanggil oleh Turn Manager / Handler
func reset_block() -> void:
	match block_reset_type:
		BlockResetType.RESET_ALL:
			self.block = 0
		BlockResetType.RETAIN_ALL:
			pass # Biarkan nilai block tetap utuh dan menumpuk
		BlockResetType.DECAY_HALF:
			self.block = floori(block / 2.0) 


# Fungsi matematika generik untuk kalkulasi pengurangan HP saat terkena serangan kartu/musuh 
func take_damage(amount: int) -> void:
	if amount <= 0:
		return
		
	# Aturan dasar roguelike card game: kurangi Armor/Block terlebih dahulu 
	if block > 0:
		var damage_mitigated = min(block, amount)
		block -= damage_mitigated
		amount -= damage_mitigated
		
	# Sisa damage yang lolos dari Block baru memotong HP asli 
	if amount > 0:
		health -= amount

func _set_charge_stacks(value: int) -> void:
	charge_stacks = maxi(0, value) # Pastikan tidak pernah minus
	stats_changed.emit()

func consume_charge() -> void:
	if charge_stacks > 0:
		self.charge_stacks = 0

func create_instance() -> Resource:
	var instance: Stats = self.duplicate()
	instance.health = max_health
	instance.block = 0
	return instance
