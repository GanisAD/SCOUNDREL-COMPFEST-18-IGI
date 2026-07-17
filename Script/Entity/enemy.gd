class_name Enemy
extends Area2D

# Sinyal kematian musuh yang akan ditangkap oleh EnemyHandler
signal died(enemy: Enemy)

# Inject data EnemyStats ke musuh ini lewat Inspector
@export var stats: EnemyStats

# Onready variables untuk memetakan node child di Scene musuh
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui = $StatsUI  # Menghubungkan ke UI HP & Block musuh

func _ready() -> void:
	# 1. Gandakan resource stats agar data HP musuh ini tidak berbagi dengan musuh lain
	if stats:
		stats = stats.create_instance() as EnemyStats
		# Inject data EnemyStats ke UI generik. UI akan otomatis mengurus signal-nya!
		stats_ui.stats = stats
	
	# 2. Sembunyikan indikator panah target di awal pertempuran
	if arrow:
		arrow.visible = false
		
	# 3. Hubungkan sinyal internal Area2D untuk sistem hover aiming kartu
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# --- MANAJEMEN VISUAL ---

func _update_visuals() -> void:
	if stats:
		if sprite_2d and stats.art:
			sprite_2d.texture = stats.art
		if stats_ui:
			stats_ui.update_hud(stats) # Panggil fungsi update di StatsUI kamu

func _on_stats_changed() -> void:
	if stats_ui and stats:
		stats_ui.update_stats(stats)

# --- DETEKSI HOVER PENARGETAN KARTU (AIMING) ---

func _on_area_entered(area: Area2D) -> void:
	# Pastikan Card Target Selector kamu didaftarkan dalam Group bernama "card_target_selector"
	if area.is_in_group("card_target_selector"):
		if arrow:
			arrow.visible = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("card_target_selector"):
		if arrow:
			arrow.visible = false

# --- LOGIKA DAMAGE & GAMEPLAY ---

# Fungsi publik yang akan dipanggil oleh kartu pemain (DamageEffect)
func take_damage(amount: int) -> void:
	if not stats:
		return
		
	stats.take_damage(amount)
	
	# Berikan efek feedback visual instan saat terkena serangan
	_play_hit_effect()
	
	# Cek apakah HP habis
	if stats.health <= 0:
		died.emit(self)
		queue_free()

# Efek visual flash merah singkat saat terkena damage
func _play_hit_effect() -> void:
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.1)

# --- TURNS & AI LOGIC (CO-ROUTINE FRIENDLY) ---

# Fungsi ini dipanggil bergiliran oleh EnemyHandler di turn musuh.
# Menggunakan await agar EnemyHandler menunggu gerakan musuh ini selesai sebelum berpindah ke musuh berikutnya.
func do_turn() -> void:
	# Cari referensi Player dari grup "player" untuk dijadikan target serang
	var players = get_tree().get_nodes_in_group("player")
	var target_player = players[0] if not players.is_empty() else null
	
	# Buat Tween animasi menyerang (Maju menyeruduk ke kiri lalu kembali)
	var tween = create_tween()
	
	if target_player:
		print(stats.enemy_name, " menyerang Player!")
		
		# 1. Animasi maju menyerang ke arah kiri (posisi player)
		tween.tween_property(sprite_2d, "global_position", global_position + Vector2(-40, 0), 0.2)\
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		# 2. Callback untuk memberikan damage di tengah animasi tubrukan
		tween.tween_callback(func():
			if is_instance_valid(target_player):
				# Contoh musuh memberikan 6 damage statis untuk fase testing
				target_player.take_damage(6)
		)
		
		# 3. Animasi kembali mundur ke posisi semula
		tween.tween_property(sprite_2d, "global_position", global_position, 0.25)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		# Jika Player tidak ditemukan (untuk test isolasi musuh), musuh hanya akan menambah Block
		print(stats.enemy_name, " bertahan karena tidak ada target!")
		#tween.tween_property(sprite_2d, "scale", Vector2(1.2, 1.2), 0.15)
		tween.tween_callback(func(): stats.block += 5)
		#tween.tween_property(sprite_2d, "scale", Vector2(1.0, 1.0), 0.15)
	
	# Tahan eksekusi fungsi do_turn() sampai seluruh animasi Tween selesai
	await tween.finished

# Dipanggil di awal giliran Player untuk memperbarui rencana tindakan musuh (Intent)
func update_intent() -> void:
	# TODO: Tampilkan ikon pedang jika berniat menyerang, atau perisai jika berniat bertahan.
	# Kita bisa menghubungkannya dengan AI Resource di fase berikutnya!
	pass
