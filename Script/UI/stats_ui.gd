class_name StatsUI
extends Control

var stats: Stats : set = set_stats

@onready var hp_bar: TextureProgressBar = $HPBar
@onready var block_label: Label = $BlockLabel

func _ready() -> void:
	# Memastikan UI diperbarui begitu node siap di Scene Tree
	update_hud()

func set_stats(value: Stats) -> void:
	if stats and stats.stats_changed.is_connected(update_hud):
		stats.stats_changed.disconnect(update_hud)
		
	stats = value
	
	if stats:
		if not stats.stats_changed.is_connected(update_hud):
			stats.stats_changed.connect(update_hud)
		update_hud()

func update_hud() -> void:
	# Jika node belum _ready atau stats kosong, hentikan fungsi agar tidak crash
	if not stats or not is_node_ready(): 
		return
	
	hp_bar.max_value = stats.max_health
	hp_bar.value = stats.health
	
	if stats.block > 0:
		block_label.text = "Block: %d" % stats.block
		block_label.show()
	else:
		block_label.hide()
