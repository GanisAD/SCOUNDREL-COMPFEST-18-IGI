extends Node2D
class_name Combat # (atau Battle)

@export var character_stats: CharacterStats

@onready var battle_ui: CanvasLayer = $BattleUI
@onready var player_handler: PlayerHandler = $PlayerHandler

func _ready() -> void:
	var battle_stats = character_stats.duplicate(true)
	
	# Distribusi data sekarang HANYA ke Handler dan UI
	battle_ui.initialize_player(battle_stats)
	
	Events.player_turn_ended.connect(player_handler.end_turn)
	Events.player_hand_discarded.connect(player_handler.start_turn)
	
	battle_stats.set_health(battle_stats.max_health)
	battle_stats.set_mana(battle_stats.max_mana)
	
	# Orkestrator memantau kematian pemain secara langsung
	battle_stats.stats_changed.connect(_on_player_stats_changed.bind(battle_stats))
	
	player_handler.start_battle(battle_stats)

# Fungsi baru di orkestrator untuk mengecek Game Over
func _on_player_stats_changed(stats: CharacterStats) -> void:
	if stats.health <= 0:
		Events.player_died.emit()
		print("Game Over: Pemain Kalah!")
