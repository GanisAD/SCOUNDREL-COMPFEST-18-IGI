# enemy_action.gd
class_name EnemyAction
extends Node

# Sinyal untuk memberi tahu EnemyHandler bahwa visualisasi aksi sudah selesai
signal enemy_action_completed

@export_category("Intent Settings")
@export var intent: Intent

@export_category("AI Weight Settings")
# Bobot peluang dasar untuk algoritma Weighted Random
@export var weight: float = 1.0 

# Akumulasi bobot yang akan dihitung oleh EnemyActionPicker secara dinamis
var accumulated_weight: float = 0.0

# 1. Fungsi Logika: Apakah aksi kondisional ini siap dijalankan?
# Akan diplay/override oleh aksi yang memiliki syarat khusus (misal: HP <= 5)
func is_performable() -> bool:
	return false

# 2. Fungsi Eksekusi: Apa yang terjadi saat aksi ini dipilih?
# Fungsi ini wajib di-override di skrip anak untuk menentukan mekanik aslinya.
func perform_action(enemy: Enemy, player: PlayerHandler) -> void:
	pass
