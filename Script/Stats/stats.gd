extends Resource
class_name Stats 

# Sinyal global internal untuk memberi tahu UI agar mendesain ulang teks HP/Block secara realtime 
signal stats_changed 

@export_group("Visual & Base Config")
@export var max_health: int = 35 
@export var art: Texture2D # Sprite visual karakter 

# Menggunakan pola Setter bawaan Godot 4 agar setiap perubahan angka langsung memicu pembaruan UI 
var health: int : set = set_health 
var block: int : set = set_block 

func set_health(value: int) -> void:
	health = clamp(value, 0, max_health) 
	stats_changed.emit() # UI akan langsung mendeteksi sinyal ini 

func set_block(value: int) -> void:
	block = max(0, value) 
	stats_changed.emit() 

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
