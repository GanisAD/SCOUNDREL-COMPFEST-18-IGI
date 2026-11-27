extends Node2D
class_name Combat

@export var character_stats: CharacterStats
@export var bgm_exploration: AudioStream
@export var bgm_combat: AudioStream

# Opsional: Isi di Inspector untuk testing langsung scene combat.tscn (F6)
# tanpa harus melewati scene eksplorasi terlebih dahulu
@export var debug_encounter: Array[EnemyStats] = []

@onready var battle_ui: CanvasLayer = $BattleUI
@onready var enemy_handler: EnemyHandler = $EnemyHandler

@onready var draw_pile_label: CardPileUI = $BattleUI/CardPileUI/DrawPileLabel
@onready var discard_pile_label: CardPileUI = $BattleUI/CardPileUI/DiscardPileLabel

var current_battle_stats: CharacterStats
var is_battle_over: bool = false

func _ready() -> void:
	# Gunakan bgm_combat jika diisi, jika tidak lanjutkan bgm_exploration
	BGMManager.play_bgm(bgm_combat if bgm_combat else bgm_exploration)
	
	# 1. SETUP STATUS PEMAIN AWAL
	var battle_stats = character_stats.duplicate(true)
	current_battle_stats = battle_stats
	battle_ui.initialize_player(battle_stats)
	
	var ph = get_node_or_null("/root/PlayerHandler")
	if ph and ph.inventory_data:
		battle_ui.initialize_inventory(ph.inventory_data)
	
	battle_stats.set_health(battle_stats.max_health)
	battle_stats.set_mana(battle_stats.max_mana)
	battle_stats.stats_changed.connect(_on_player_stats_changed.bind(battle_stats))

	# 2. SETUP & SPAWN ENCOUNTER MUSUH
	# Tetap dengarkan sinyal jika encounter dikirim via Event Bus
	if Events.has_signal("combat_start"):
		Events.combat_start.connect(_on_combat_start)
	_initialize_enemies()
	
	# 3. INISIALISASI DECK & UI PILE
	PlayerHandler.start_battle(battle_stats)
	draw_pile_label.target_pile = PlayerHandler.draw_pile
	discard_pile_label.target_pile = PlayerHandler.discard_pile
	
	# 4. RANTAI EVENT TURN MANAGER
	# a. Pemain klik End Turn -> PlayerHandler buang sisa kartu di tangan
	Events.player_turn_ended.connect(PlayerHandler.end_turn)
	
	# b. Kartu selesai dibuang -> Reset block lama musuh & mulai giliran musuh
	Events.player_hand_discarded.connect(_on_player_hand_discarded)
	
	# c. Seluruh musuh selesai beraksi -> Giliran pemain dimulai kembali
	enemy_handler.enemy_turn_ended.connect(_start_player_turn)
	
	# 5. KONDISI MENANG
	enemy_handler.all_enemies_defeated.connect(_on_victory)
	
	# 6. MULAI SIKLUS GILIRAN PERTAMA
	_start_player_turn()

# --- INISIALISASI MUSUH ---

func _initialize_enemies() -> void:
	# Prioritas 1: Ambil daftar musuh dari GameManager (jika masuk dari pintu Club)
	if GameManager.get("current_encounter") and not GameManager.current_encounter.is_empty():
		enemy_handler.setup_encounter(GameManager.current_encounter)
	# Prioritas 2: Gunakan debug_encounter jika mengetes scene combat.tscn langsung
	elif not debug_encounter.is_empty():
		enemy_handler.setup_encounter(debug_encounter)

func _on_combat_start(enemy_roster: Array[EnemyStats]) -> void:
	enemy_handler.setup_encounter(enemy_roster)
	enemy_handler.update_enemy_intents()

# --- SIKLUS GILIRAN ---

func _start_player_turn() -> void:
	if is_battle_over:
		return
		
	# Musuh merencanakan & menampilkan Intent baru di atas kepala mereka
	enemy_handler.update_enemy_intents()
	
	await battle_ui.show_turn_banner("PLAYER TURN")
	battle_ui._on_player_turn_started()
	
	# Player reset block & mana, lalu menarik kartu
	PlayerHandler.start_turn()

func _on_player_hand_discarded() -> void:
	if is_battle_over:
		return
		
	# Hapus sisa armor/block musuh dari turn sebelumnya sebelum mereka bertindak
	enemy_handler.reset_enemy_blocks()
	enemy_handler.start_enemy_turn()

# --- WIN / LOSE STATE ---

func _on_player_stats_changed(stats: CharacterStats) -> void:
	if stats.health <= 0 and not is_battle_over:
		is_battle_over = true
		Events.player_died.emit()
		print("Game Over: Pemain Kalah!")

func _on_victory() -> void:
	if is_battle_over:
		return
	is_battle_over = true
	
	print("Victory! Semua musuh telah dikalahkan.")
	if current_battle_stats:
		GameManager.player_hp = current_battle_stats.health
		GameManager.max_hp = current_battle_stats.max_health
	Events.combat_victory.emit()
	GameManager.return_to_dungeon_overworld()
