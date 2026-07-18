class_name EnemyHandler
extends Node

# Signal untuk memberi tahu Battle Manager tentang status pertempuran
signal enemy_turn_ended
signal all_enemies_defeated

# Array statis ber-tipe untuk melacak musuh yang masih hidup di arena
var active_enemies: Array[Enemy] = []

func _ready() -> void:
	# Inisialisasi awal saat pertempuran dimulai
	_update_active_enemies()
	_setup_enemy_signals()

# Fungsi internal untuk mendata ulang musuh yang aktif di bawah Node ini
func _update_active_enemies() -> void:
	active_enemies.clear()
	for child in get_children():
		if child is Enemy:
			active_enemies.append(child)

# Menghubungkan signal kematian dari setiap musuh
func _setup_enemy_signals() -> void:
	for enemy in active_enemies:
		# Menggunakan signal kustom 'died' dari musuh agar lebih aman sebelum queue_free
		if enemy.has_signal("died") and not enemy.died.is_connected(_on_enemy_died):
			enemy.died.connect(_on_enemy_died.bind(enemy))

# --- LOGIKA TURN-BASED (SEKUENSAL) ---

# Dipanggil oleh Battle Manager saat giliran Player selesai
func start_enemy_turn() -> void:
	_update_active_enemies()
	
	if active_enemies.is_empty():
		all_enemies_defeated.emit()
		return
	
	# Iterasi musuh satu per satu secara berurutan agar visual terlihat rapi
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			# Menunggu aksi musuh selesai (misal: animasi serang, kalkulasi damage ke player)
			# Pastikan fungsi do_turn() di skrip Enemy kamu mengembalikan coroutine (await)
			await enemy.do_turn()
			
			# Jeda singkat sebelum musuh berikutnya menyerang untuk memberikan efek dramatis
			await get_tree().create_timer(0.4).timeout
	
	# Beritahu Battle Manager bahwa seluruh musuh selesai bertindak
	enemy_turn_ended.emit()

# --- UTILITY & MAINTENANCE ---

# Dipanggil di awal giliran Player atau giliran Enemy untuk mereset armor/block musuh
func reset_enemy_blocks() -> void:
	_update_active_enemies()
	for enemy in active_enemies:
		if is_instance_valid(enemy) and enemy.stats:
			enemy.stats.block = 0

# Meminta setiap musuh merencanakan dan menampilkan aksi mereka berikutnya (Intent)
# Biasanya dipanggil di awal Turn Player agar Player bisa menyusun strategi
func update_enemy_intents() -> void:
	_update_active_enemies()
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.update_intent()

# --- PENANGANAN KEMATIAN MUSUH ---

# Callback saat ada musuh yang mati
func _on_enemy_died(enemy: Enemy) -> void:
	if enemy in active_enemies:
		active_enemies.erase(enemy)
	
	# Cek apakah ini musuh terakhir yang mati di arena
	if active_enemies.is_empty():
		# Pemicu kemenangan untuk Battle Manager!
		all_enemies_defeated.emit()
