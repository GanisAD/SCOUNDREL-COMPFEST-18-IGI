## Entitas musuh dalam pertempuran turn-based.
## Mengelola siklus giliran AI (EnemyActionPicker), rendering intent telegraph (IntentUI),
## kalkulasi pertahanan (StatsUI), animasi terkena serangan, dan pemicu audio luka/kematian.
class_name Enemy
extends Area2D

## Sinyal kematian musuh yang dipancarkan saat HP mencapai 0.
signal died

## Resource statistik musuh (EnemyStats) yang menentukan HP, Base Block, dan visual sprite.
@export var stats: EnemyStats : set = set_enemy_stats

# [TAMBAHAN] Menyimpan aksi aktif yang direncanakan untuk giliran ini
var current_action: EnemyAction : set = _set_current_action

# Onready variables untuk memetakan node child di Scene musuh
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui = $StatsUI  # Menghubungkan ke UI HP & Block musuh

# [TAMBAHAN] Ambil referensi picker AI musuh
@onready var enemy_action_picker: EnemyActionPicker = $EnemyActionPicker
@onready var intent_ui = $IntentUI # Asumsi node IntentUI ditempel di scene musuh

var base_sprite_scale: Vector2 = Vector2.ONE
var base_modulate: Color = Color.WHITE

func _ready() -> void:
	add_to_group("enemies")
	
	# Sembunyikan indikator panah target di awal pertempuran
	if arrow:
		arrow.visible = false
	
	if sprite:
		base_sprite_scale = sprite.scale
		base_modulate = sprite.modulate
		play_animation("idle")
	
	# Hubungkan sinyal internal Area2D untuk sistem hover aiming kartu
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

# Setter aman untuk stats (berfungsi baik sebelum maupun sesudah _ready)
func set_enemy_stats(value: EnemyStats) -> void:
	if stats and stats.stats_changed.is_connected(_on_stats_changed):
		stats.stats_changed.disconnect(_on_stats_changed)
		
	if value:
		stats = value.create_instance() as EnemyStats
	else:
		stats = null
		
	if not is_node_ready():
		await ready
		
	update_stats()
	setup_ai()

func update_stats() -> void:
	if not stats:
		return
		
	if not stats.stats_changed.is_connected(_on_stats_changed):
		stats.stats_changed.connect(_on_stats_changed)
		
	if stats_ui:
		stats_ui.stats = stats
		stats_ui.update_hud()
		
	_update_visuals()

func setup_ai() -> void:
	if stats and stats.ai:
		if enemy_action_picker:
			enemy_action_picker.queue_free()
		var new_picker := stats.ai.instantiate() as EnemyActionPicker
		if new_picker:
			add_child(new_picker)
			enemy_action_picker = new_picker
	elif not enemy_action_picker:
		enemy_action_picker = get_node_or_null("EnemyActionPicker") as EnemyActionPicker
		
	if enemy_action_picker:
		enemy_action_picker.enemy = self
		enemy_action_picker.target = _get_player_node()
		enemy_action_picker.setup_actions()

# --- MANAJEMEN VISUAL ---

func _update_visuals() -> void:
	if stats:
		if sprite and stats.art and "texture" in sprite:
			sprite.texture = stats.art
		if stats_ui:
			stats_ui.update_hud() 

# [MODIFIKASI] Dipanggil otomatis saat sinyal stats_changed aktif
func _on_stats_changed() -> void:
	if stats_ui and stats:
		stats_ui.update_hud()
	
	# Perbarui tampilan angka intent (misal jika damage berubah karena buff/debuff),
	# TANPA mengacak ulang aksi yang telah direncanakan untuk giliran ini!
	update_intent_display()

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
	base_modulate = rage_color
	var tween = create_tween().set_parallel(true)
	tween.bind_node(self)
	
	# 1. Ubah warna modulate sprite secara permanen
	tween.tween_property(sprite, "modulate", base_modulate, 0.35)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
	# 2. Denyut membesar singkat (Juice Effect)
	var scale_tween = create_tween()
	scale_tween.bind_node(self)
	scale_tween.tween_property(sprite, "scale", base_sprite_scale * 1.2, 0.15)
	scale_tween.tween_property(sprite, "scale", base_sprite_scale, 0.15)
	
	# Tunggu animasi selesai agar aksi tidak terputus prematur
	await scale_tween.finished

# Animasi visual saat musuh menambah Block
func play_block_animation() -> void:
	if not sprite:
		return
		
	var tween = create_tween()
	tween.bind_node(self)
	tween.tween_property(sprite, "scale", base_sprite_scale * 1.15, 0.1)
	tween.tween_property(sprite, "scale", base_sprite_scale, 0.1)
	
	await tween.finished

# [TAMBAHAN] Setter untuk mendeteksi perubahan aksi dan memperbarui UI Intent
func _set_current_action(value: EnemyAction) -> void:
	current_action = value
	update_intent_display()

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
		died.emit()
		queue_free()

func _play_hit_effect() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", base_modulate, 0.1)

func add_block(amount: int) -> void:
	if not stats:
		return
		
	# Memodifikasi stats.block otomatis memancarkan sinyal stats_changed ke StatsUI
	stats.block += amount

# Efek visual sederhana saat musuh menambah pertahanan/block

# --- TURNS & AI LOGIC (CO-ROUTINE FRIENDLY) ---

# [MODIFIKASI TOTAL] Menggunakan arsitektur EnemyAction baru
func do_turn() -> void:
	if not enemy_action_picker or not current_action:
		return
		
	var target_player = _get_player_node()
	
	# --- MEKANISME FAILSAFE MENGGUNAKAN REFERENCE ---
	# Menggunakan Dictionary agar lambda bisa memodifikasi nilainya secara eksternal
	var flags = { "action_done": false }
	var failsafe_timer = get_tree().create_timer(1.5)
	
	# Hubungkan sinyal selesai yang asli ke lambda (one-shot agar tidak menumpuk antar turn)
	current_action.enemy_action_completed.connect(func():
		flags["action_done"] = true
	, CONNECT_ONE_SHOT)
	
	# Eksekusi aksi musuh
	current_action.perform_action(self, target_player)
	
	# Tunggu mana yang lebih cepat: Aksi selesai secara normal, ATAU waktu failsafe habis
	while not flags["action_done"]:
		if not is_instance_valid(self) or not is_inside_tree():
			return
		await get_tree().process_frame
		if failsafe_timer.time_left <= 0:
			print("WARNING: Aksi musuh ", stats.enemy_name if stats else name, " macet! Failsafe dipicu.")
			break
	
	# --- PEMBERSIHAN ---
	current_action = null
	if intent_ui:
		intent_ui.hide()

# [MODIFIKASI] Dipanggil di awal giliran Player untuk merencanakan aksi musuh pada giliran ini
func update_intent() -> void:
	_connect_player_stats()
	if enemy_action_picker:
		# Minta picker memilih aksi berdasarkan logika prioritas/peluang
		current_action = enemy_action_picker.get_action()
		update_intent_display()

# Memperbarui tampilan Intent UI berdasarkan current_action saat ini tanpa memilih ulang aksi
func update_intent_display() -> void:
	if intent_ui and current_action:
		intent_ui.update_intent(current_action, self)
	elif intent_ui:
		intent_ui.hide()

func _get_player_node() -> Node:
	if not is_inside_tree():
		return null
	var players = get_tree().get_nodes_in_group("player")
	return players[0] if not players.is_empty() else null

func _connect_player_stats() -> void:
	var player = _get_player_node()
	if player and "character_stats" in player and player.character_stats:
		if not player.character_stats.stats_changed.is_connected(update_intent_display):
			player.character_stats.stats_changed.connect(update_intent_display)

func _exit_tree() -> void:
	var player = _get_player_node()
	if player and "character_stats" in player and player.character_stats:
		if player.character_stats.stats_changed.is_connected(update_intent_display):
			player.character_stats.stats_changed.disconnect(update_intent_display)
