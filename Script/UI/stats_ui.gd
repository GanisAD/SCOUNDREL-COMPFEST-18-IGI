class_name StatsUI
extends Control

# Poin Krusial: Gunakan base class 'Stats' agar bisa menerima Player (CharacterStats) 
# maupun Enemy (EnemyStats) secara universal.
var stats: Stats : set = set_stats

# Referensi node dibuat lokal/relatif terhadap komponen ini sendiri
@onready var hp_label: Label = $HPLabel
@onready var block_label: Label = $BlockLabel

func set_stats(value: Stats) -> void:
	# Pengaman: Jika ganti stats di tengah jalan, putus koneksi lama agar tidak leak memori
	if stats and stats.stats_changed.is_connected(update_hud):
		stats.stats_changed.disconnect(update_hud)
		
	stats = value
	
	if stats:
		if not stats.stats_changed.is_connected(update_hud):
			stats.stats_changed.connect(update_hud)
		update_hud()

# Fungsi render generik yang tidak peduli ini milik player atau musuh
func update_hud() -> void:
	if not stats or not is_inside_tree(): 
		return
	
	# Mengambil data langsung dari resource yang di-inject
	hp_label.text = "HP: %d/%d" % [stats.health, stats.max_health]
	
	if stats.block > 0:
		block_label.text = "Block: %d" % stats.block
		block_label.show()
	else:
		block_label.hide()
