class_name Enemy
extends Area2D

# Sinyal kematian musuh yang akan ditangkap oleh EnemyHandler
signal died(enemy: Enemy)

# Inject data EnemyStats ke musuh ini lewat Inspector
@export var stats: EnemyStats

# [TAMBAHAN] Menyimpan aksi aktif yang direncanakan untuk giliran ini
var current_action: EnemyAction : set = _set_current_action

# Onready variables untuk memetakan node child di Scene musuh
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui = $StatsUI  # Menghubungkan ke UI HP & Block musuh

# [TAMBAHAN] Ambil referensi picker AI musuh
@onready var enemy_action_picker: EnemyActionPicker = $EnemyActionPicker
@onready var intent_ui = $IntentUI # Asumsi node IntentUI ditempel di scene musuh

func _ready() -> void:
	add_to_group("enemies")
	# 1. Gandakan resource stats agar data HP musuh ini tidak berbagi dengan musuh lain
	if stats:
		stats = stats.create_instance() as EnemyStats
		stats_ui.stats = stats
		
		# [TAMBAHAN] Hubungkan sinyal perubahan status untuk sistem Reactive Intent
		# Jika HP musuh berubah akibat diserang player, ia akan mengecek ulang aksinya
		stats.stats_changed.connect(_on_stats_changed)
	
	# 2. Sembunyikan indikator panah target di awal pertempuran
	if arrow:
		arrow.visible = false
	
	if sprite:
		sprite.play("idle")
	
	# 3. Hubungkan sinyal internal Area2D untuk sistem hover aiming kartu
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# --- MANAJEMEN VISUAL ---

func _update_visuals() -> void:
	if stats:
		if sprite and stats.art:
			sprite.texture = stats.art
		if stats_ui:
			stats_ui.update_hud(stats) 

# [MODIFIKASI] Dipanggil otomatis saat sinyal stats_changed aktif
func _on_stats_changed() -> void:
	if stats_ui and stats:
		stats_ui.update_hud()
	
	# [TAMBAHAN] Reactive Intent: Cek ulang AI jika HP berkurang, 
	# siapa tahu memicu Conditional Action (seperti Mega Block) secara real-time!
	update_intent()

# --- VISUAL & ANIMATION INTERFACES ---

func play_animation(anim_name: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)

# Koreografi fisik serangan (Tween + Animasi Frame)
func play_attack_animation(target_offset: Vector2, on_impact_callback: Callable) -> void:
	if not sprite:
		return
		
	var original_pos = global_position
	play_animation("attack")
	
	var tween = create_tween()
	tween.bind_node(self)
	
	# 1. Ancang-ancang & terjang maju
	tween.tween_property(self, "global_position", original_pos + Vector2(15, 0), 0.15)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", original_pos + target_offset, 0.15)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# 2. Frame Kontak: Panggil logika damage dari Action
	tween.tween_callback(on_impact_callback)
	
	# 3. Jeda kontak (impact hold) & meluncur mundur
	tween.tween_interval(0.08)
	tween.tween_property(self, "global_position", original_pos, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# 4. Tunggu hingga fisik dan frame sprite selesai sepenuhnya
	await tween.finished
	if sprite.is_playing() and sprite.animation == "attack":
		await sprite.animation_finished
		
	play_animation("idle")

func play_buff_animation() -> void:
	if not sprite:
		return
		
	var rage_color = Color.from_string("ffd043", Color.ORANGE)
	var tween = create_tween().set_parallel(true)
	tween.bind_node(self)
	
	# 1. Ubah warna modulate sprite secara permanen
	tween.tween_property(sprite, "modulate", rage_color, 0.35)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	# 2. Denyut membesar singkat (Juice Effect)
	var scale_tween = create_tween()
	scale_tween.bind_node(self)
	scale_tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.15)
	scale_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.15)
	
	# Tunggu animasi selesai agar aksi tidak terputus prematur
	await scale_tween.finished

# Animasi visual saat musuh menambah Block
func play_block_animation() -> void:
	if not sprite:
		return
		
	var tween = create_tween()
	tween.bind_node(self)
	tween.tween_property(sprite, "scale", Vector2(1.15, 1.15), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	await tween.finished

# [TAMBAHAN] Setter untuk mendeteksi perubahan aksi dan memperbarui UI Intent
func _set_current_action(value: EnemyAction) -> void:
	current_action = value
	if intent_ui and current_action:
		intent_ui.update_intent(current_action.intent)

# --- DETEKSI HOVER PENARGETAN KARTU (AIMING) ---

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("card_target_selector"):
		if arrow:
			arrow.visible = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("card_target_selector"):
		if arrow:
			arrow.visible = false

# --- LOGIKA DAMAGE & GAMEPLAY ---

func take_damage(amount: int) -> void:
	if not stats:
		return
		
	stats.take_damage(amount)
	_play_hit_effect()
	
	if stats.health <= 0:
		died.emit(self)
		queue_free()

func _play_hit_effect() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

func add_block(amount: int) -> void:
	if not stats:
		return
		
	# Tambahkan nilai block ke dalam stats musuh
	stats.block += amount
	
	# Berikan sedikit feedback visual (misal: efek bergetar/skala membesar singkat)
	_play_block_effect()
	
	# Memicu pembaruan UI secara manual jika diperlukan 
	# (Jika stats_changed tidak otomatis terpicu saat variabel .block berubah)
	_on_stats_changed()

# Efek visual sederhana saat musuh menambah pertahanan/block
func _play_block_effect() -> void:
	var tween = create_tween()
	# Membuat sprite membesar sedikit lalu kembali normal untuk memberi kesan memompa pertahanan
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

# --- TURNS & AI LOGIC (CO-ROUTINE FRIENDLY) ---

# [MODIFIKASI TOTAL] Menggunakan arsitektur EnemyAction baru
# enemy.gd
func do_turn() -> void:
	if not enemy_action_picker or not current_action:
		return
		
	var players = get_tree().get_nodes_in_group("player")
	var target_player = players[0] if not players.is_empty() else null
	
	# --- MEKANISME FAILSAFE MENGGUNAKAN REFERENCE ---
	# Menggunakan Dictionary agar lambda bisa memodifikasi nilainya secara eksternal
	var flags = { "action_done": false }
	var failsafe_timer = get_tree().create_timer(1.5)
	
	# Hubungkan sinyal selesai yang asli ke lambda
	current_action.enemy_action_completed.connect(func():
		flags["action_done"] = true
	)
	
	# Eksekusi aksi musuh
	current_action.perform_action(self, target_player)
	
	# Tunggu mana yang lebih cepat: Aksi selesai secara normal, ATAU waktu failsafe habis
	while not flags["action_done"]:
		await get_tree().process_frame
		if failsafe_timer.time_left <= 0:
			print("WARNING: Aksi musuh ", stats.enemy_name, " macet! Failsafe dipicu.")
			break
	
	# --- PEMBERSIHAN ---
	if intent_ui:
		intent_ui.hide()

# [MODIFIKASI] Dipanggil di awal giliran Player (atau saat HP musuh berubah)
func update_intent() -> void:
	if enemy_action_picker:
		# Minta picker memilih aksi berdasarkan logika prioritas/peluang
		current_action = enemy_action_picker.get_action()
		if intent_ui and current_action:
			intent_ui.show()
