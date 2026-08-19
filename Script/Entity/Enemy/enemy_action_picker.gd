# enemy_action_picker.gd
class_name EnemyActionPicker
extends Node

# Daftar internal untuk memisahkan jenis aksi
var conditional_actions: Array[EnemyAction] = []
var chance_actions: Array[EnemyAction] = []
var total_weight: float = 0.0

func _ready() -> void:
	setup_actions()

# 1. Mengelompokkan aksi dan menghitung bobot kumulatif saat inisialisasi
func setup_actions() -> void:
	conditional_actions.clear()
	chance_actions.clear()
	total_weight = 0.0
	
	for child in get_children():
		if child is EnemyAction:
			# Cek apakah aksi ini memiliki logika kondisional yang di-override
			# (Secara default di base class, is_performable() mengembalikan false)
			if child.has_method("is_performable") and child.is_performable():
				# Kita masukkan ke daftar kondisional. 
				# NOTE: Kondisi asli di-cek secara real-time saat get_action(), 
				# tapi kita kelompokkan dulu polanya di sini jika dia punya potensi kondisional.
				conditional_actions.append(child)
			else:
				chance_actions.append(child)
				total_weight += child.weight
				child.accumulated_weight = total_weight

# 2. Fungsi Utama: Menentukan aksi mana yang akan diambil
func get_action() -> EnemyAction:
	# STRATEGI 1: Evaluasi aksi kondisional terlebih dahulu (Prioritas Utama)
	for action in get_children():
		if action is EnemyAction and action.is_performable():
			return action
			
	# STRATEGI 2: Jika tidak ada kondisi terpenuhi, gunakan Weighted Random
	if chance_actions.is_empty():
		return null
		
	var roll: float = randf_range(0.0, total_weight)
	
	for action in chance_actions:
		if roll <= action.accumulated_weight:
			return action
			
	return chance_actions.back() # Fallback aman jika terjadi pembulatan float float
