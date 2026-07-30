extends Node2D
class_name Combat 

@export var character_stats: CharacterStats

@onready var battle_ui: CanvasLayer = $BattleUI
#@onready var PlayerHandler: PlayerHandler = $PlayerHandler
@onready var enemy_handler: EnemyHandler = $EnemyHandler # Pastikan referensi ini ada

@onready var draw_pile_label: CardPileUI = $BattleUI/CardPileUI/DrawPileLabel
@onready var discard_pile_label: CardPileUI = $BattleUI/CardPileUI/DiscardPileLabel


func _ready() -> void:
	var battle_stats = character_stats.duplicate(true)
	battle_ui.initialize_player(battle_stats)
	
	# 1. SETUP STATUS PEMAIN AWAL
	battle_stats.set_health(battle_stats.max_health)
	battle_stats.set_mana(battle_stats.max_mana)
	battle_stats.stats_changed.connect(_on_player_stats_changed.bind(battle_stats))
	
	PlayerHandler.start_battle(battle_stats)
	
	draw_pile_label.target_pile = PlayerHandler.draw_pile
	discard_pile_label.target_pile = PlayerHandler.discard_pile
	
	# 2. RANTAI EVENT TURN MANAGER YANG BENAR
	# a. Pemain selesai -> Player Handler buang kartu
	Events.player_turn_ended.connect(PlayerHandler.end_turn)
	
	# b. Kartu selesai dibuang -> Giliran Musuh Dimulai
	Events.player_hand_discarded.connect(enemy_handler.start_enemy_turn)
	
	# c. Musuh selesai beraksi -> Giliran Pemain Dimulai kembali (Pakai Sinyal Lokal EnemyHandler)
	enemy_handler.enemy_turn_ended.connect(_start_player_turn)
	
	# 3. KONDISI MENANG / KALAH
	enemy_handler.all_enemies_defeated.connect(_on_victory)
	
	# Mulai turn
	_start_player_turn() # Panggil siklus giliran pertama

# --- SIKLUS GILIRAN ---

func _start_player_turn() -> void:
	# 1. Enemy Reset Armor & Rencanakan Serangan Baru (Tampil di UI)
	enemy_handler.reset_enemy_blocks()
	enemy_handler.update_enemy_intents()
	
	battle_ui.show_turn_banner("PLAYER TURN")
	battle_ui._on_player_turn_started()
	
	# 2. Player Reset Mana & Tarik Kartu
	PlayerHandler.start_turn()

# --- WIN / LOSE STATE ---

func _on_player_stats_changed(stats: CharacterStats) -> void:
	if stats.health <= 0:
		Events.player_died.emit()
		print("Game Over: Pemain Kalah!")

func _on_victory() -> void:
	print("Victory! Semua musuh telah dikalahkan.")
	GameManager.return_to_dungeon_overworld()
