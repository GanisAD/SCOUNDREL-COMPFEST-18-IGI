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

# Referensi runtime yang disuntikkan oleh EnemyActionPicker
var enemy: Enemy
var target: Node

# Apakah aksi ini bertipe kondisional (bukan aksi acak berbobot biasa)
func is_conditional() -> bool:
	return false

# 1. Fungsi Logika: Apakah aksi kondisional ini siap dijalankan?
# Akan diplay/override oleh aksi yang memiliki syarat khusus (misal: HP <= 5)
func is_performable() -> bool:
	return false

# Nilai angka yang akan ditampilkan di Intent UI (misal: damage atau block)
func get_intent_value(_enemy: Enemy = null) -> String:
	if intent and intent.number != "":
		return intent.number
	return ""

# Helper untuk aksi bertipe Summon/Split agar dapat mengakses EnemyHandler
func get_enemy_handler() -> EnemyHandler:
	if not is_inside_tree():
		return null
	return get_tree().get_first_node_in_group("enemy_handler") as EnemyHandler

# 2. Fungsi Eksekusi: Apa yang terjadi saat aksi ini dipilih?
# Fungsi ini wajib di-override di skrip anak untuk menentukan mekanik aslinya.
func perform_action(_enemy: Enemy, _player: Node) -> void:
	pass
