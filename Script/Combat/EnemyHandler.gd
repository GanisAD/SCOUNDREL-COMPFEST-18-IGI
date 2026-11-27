# enemy_handler.gd
class_name EnemyHandler
extends Node2D

signal enemy_turn_ended
signal all_enemies_defeated

# Masukkan base scene Enemy.tscn di Inspector sebagai fallback
@export var default_enemy_scene: PackedScene
# Jarak horizontal antar musuh saat di-spawn otomatis
@export var enemy_spacing: float = 160.0

var active_enemies: Array[Enemy] = []

func _ready() -> void:
	# Daftarkan ke group agar EnemyAction (Summon/Split) mudah menemukan handler ini
	add_to_group("enemy_handler")
	
	# Tetap dukung jika ada musuh yang ditaruh manual di editor untuk testing
	for child in get_children():
		if child is Enemy:
			_register_enemy(child)

# --- 1. INISIALISASI ENCOUNTER (MULTIPLE ENEMIES) ---

# Dipanggil oleh Battle/Combat Manager saat masuk ruangan Club
func setup_encounter(enemy_roster: Array[EnemyStats]) -> void:
	clear_all_enemies()
	
	var count = enemy_roster.size()
	if count == 0:
		return
		
	# Hitung posisi tengah agar formasi musuh selalu simetris di battlefield
	var total_width = (count - 1) * enemy_spacing
	var start_x = -total_width / 2.0
	
	for i in range(count):
		var spawn_pos = Vector2(start_x + (i * enemy_spacing), 0)
		spawn_enemy(enemy_roster[i], spawn_pos)

# --- 2. SINGLE ENTRY-POINT SPAWNER (UNTUK ENCOUNTER, SUMMON, & SPLIT) ---

func spawn_enemy(stats: EnemyStats, local_pos: Vector2) -> Enemy:
	if not stats:
		push_error("EnemyHandler: stats belum diisi!")
		return null
		
	var scene_to_spawn: PackedScene = stats.enemy_scene if stats.enemy_scene else default_enemy_scene
	if not scene_to_spawn:
		push_error("EnemyHandler: stats.enemy_scene dan default_enemy_scene belum diisi!")
		return null
		
	var new_enemy = scene_to_spawn.instantiate() as Enemy
	new_enemy.position = local_pos
	add_child(new_enemy)
	
	# Inject stats (otomatis menduplikasi resource & setup AI di setter Enemy)
	new_enemy.stats = stats
	new_enemy.update_intent()
	
	_register_enemy(new_enemy)
	return new_enemy

# Memastikan setiap musuh (awal maupun summon) terdaftar dan terhubung signal-nya
func _register_enemy(enemy: Enemy) -> void:
	if enemy not in active_enemies:
		active_enemies.append(enemy)
		
	if enemy.has_signal("died") and not enemy.died.is_connected(_on_enemy_died):
		enemy.died.connect(_on_enemy_died.bind(enemy))

func clear_all_enemies() -> void:
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()

# --- 3. LOGIKA TURN-BASED AMAN DARI MUTASI ---

func start_enemy_turn() -> void:
	Events.enemy_turn_started.emit()
	_cleanup_invalid_enemies()
	
	if active_enemies.is_empty():
		all_enemies_defeated.emit()
		return
	
	# PENTING: Duplikasi array sebagai snapshot antrean giliran!
	# Musuh hasil summon/split di tengah turn tidak akan mengacaukan loop
	# dan baru akan bertindak pada turn berikutnya (standar Slay the Spire).
	var turn_queue: Array[Enemy] = active_enemies.duplicate()
	
	for enemy in turn_queue:
		# Cek ulang validitas karena musuh bisa saja mati oleh efek racun/split
		if is_instance_valid(enemy) and enemy in active_enemies:
			await enemy.do_turn()
			await get_tree().create_timer(0.4).timeout
	
	enemy_turn_ended.emit()

# --- 4. UTILITY & CLEANUP ---

func reset_enemy_blocks() -> void:
	_cleanup_invalid_enemies()
	for enemy in active_enemies:
		if enemy.stats:
			enemy.stats.reset_block()

func update_enemy_intents() -> void:
	_cleanup_invalid_enemies()
	for enemy in active_enemies:
		enemy.update_intent()

func _cleanup_invalid_enemies() -> void:
	active_enemies = active_enemies.filter(func(e): return is_instance_valid(e))

func _on_enemy_died(enemy: Enemy) -> void:
	active_enemies.erase(enemy)
	
	if active_enemies.is_empty():
		all_enemies_defeated.emit()