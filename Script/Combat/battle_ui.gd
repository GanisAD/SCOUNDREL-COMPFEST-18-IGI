extends CanvasLayer
class_name BattleUI

var character_stats: CharacterStats : set = set_character_stats

# Referensi ke elemen HUD pemain di layar
@onready var hp_label: Label = $PlayerStatsPanel/HPLabel
@onready var block_label: Label = $PlayerStatsPanel/BlockLabel

func set_character_stats(value: CharacterStats) -> void:
	character_stats = value
	if not character_stats.stats_changed.is_connected(update_player_hud):
		character_stats.stats_changed.connect(update_player_hud)
	update_player_hud()

func update_player_hud() -> void:
	if not character_stats: return
	
	# Render HP langsung ke HUD
	hp_label.text = "HP: %d/%d" % [character_stats.health, character_stats.max_health]
	
	# Render Block ke HUD
	if character_stats.block > 0:
		block_label.text = "Block: %d" % character_stats.block
		block_label.show()
	else:
		block_label.hide()
