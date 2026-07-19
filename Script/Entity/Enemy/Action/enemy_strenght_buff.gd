# enemy_strength_buff.gd
class_name EnemyStrengthBuff
extends EnemyAction

@export var strength_amount: int = 2
@export var min_hp_percentage: int = 50

# Flag untuk memastikan buff ini hanya terjadi sekali
var already_used: bool = false

# 1. Pengecekan Kondisi: Aktif jika HP <= 50% dan belum pernah digunakan
func is_performable() -> bool:
	var enemy = owner as Enemy
	if not enemy or not enemy.stats or already_used:
		return false
		
	# Menghitung apakah HP saat ini berada di angka 50% atau lebih rendah
	var health_threshold = enemy.stats.max_health * min_hp_percentage
	if enemy.stats.health <= health_threshold:
		return true
		
	return false

# 2. Eksekusi Buff dan Efek Visual Permanen
func perform_action(enemy: Enemy, player: PlayerHandler) -> void:
	# Tambahkan stats strength (asumsi variabel di stats bernama strength)
	enemy.stats.strength += strength_amount
	already_used = true
	
	# Memicu efek visual transisi warna di objek Enemy
	_play_rage_visuals(enemy)
	
	# Perbarui UI agar status strength baru langsung terlihat
	enemy._on_stats_changed()
	
	# Akhiri aksi agar giliran berganti
	enemy_action_completed.emit()

# Efek visual mengubah warna sprite menjadi kuning keoranyean secara halus
func _play_rage_visuals(enemy: Enemy) -> void:
	if not enemy.sprite_2d:
		return
		
	var tween = enemy.create_tween().set_parallel(true)
	
	# Mengubah warna modulate secara permanen ke warna kuning oranye hangat
	# Kamu bisa bereksperimen dengan kode Hex warna di bawah ini (misal: #ffd043)
	var rage_color = Color.from_string("ffd043", Color.ORANGE)
	
	tween.tween_property(enemy.sprite_2d, "modulate", rage_color, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	# Memberikan efek denyut/skala membesar singkat saat mengaktifkan mode ini
	var scale_tween = enemy.create_tween()
	scale_tween.tween_property(enemy.sprite_2d, "scale", Vector2(1.2, 1.2), 0.2)
	scale_tween.tween_property(enemy.sprite_2d, "scale", Vector2(1.0, 1.0), 0.2)
