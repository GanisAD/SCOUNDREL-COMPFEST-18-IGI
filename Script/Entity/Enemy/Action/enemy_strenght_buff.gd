# enemy_strength_buff.gd
class_name EnemyStrengthBuff
extends EnemyAction

@export var strength_amount: int = 2
# Gunakan range 1 - 100 agar mudah disetel di Inspector
@export_range(1.0, 100.0) var min_hp_percentage: float = 50.0

var already_used: bool = false

# 1. Pengecekan Kondisi: Aktif jika HP <= persentase batas dan belum pernah digunakan
func is_performable() -> bool:
	var enemy = owner as Enemy
	if not enemy or not enemy.stats or already_used:
		return false
		
	# Perbaikan Bug Rumus: Bagi 100.0 agar menjadi faktor desimal (misal 50% -> 0.5)
	var health_threshold = enemy.stats.max_health * (min_hp_percentage / 100.0)
	return enemy.stats.health <= health_threshold

# 2. Orkestrasi Buff
func perform_action(enemy: Enemy, player: PlayerHandler) -> void:
	# Aturan Gameplay: Tambahkan buff strength
	enemy.stats.strength_stacks += strength_amount
	already_used = true
	
	# Delegasi Visual: Minta musuh memutar visual buff dan tunggu sampai animasi tuntas
	await enemy.play_buff_animation()
	
	# Lapor ke Turn Manager bahwa giliran selesai
	enemy_action_completed.emit()
