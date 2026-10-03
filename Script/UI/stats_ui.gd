class_name StatsUI
extends Control

var stats: Stats : set = set_stats

@export var hide_block_when_zero: bool = true

@onready var hp_bar: Range = $HPBar
@onready var hp_label: Label = get_node_or_null("HPLabel") if has_node("HPLabel") else (get_node_or_null("HPBar/HPLabel") if has_node("HPBar/HPLabel") else null)
@onready var block_container: Control = get_node_or_null("BlockContainer")
@onready var block_label: Label = get_node_or_null("BlockContainer/BlockLabel") if has_node("BlockContainer/BlockLabel") else get_node_or_null("BlockLabel")

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
	
	if hp_bar:
		hp_bar.max_value = stats.max_health
		hp_bar.value = stats.health
		
	if hp_label:
		hp_label.text = "%d / %d" % [stats.health, stats.max_health]
	
	var has_block: bool = stats.block > 0
	var should_show_block: bool = has_block or not hide_block_when_zero
	
	if block_label:
		if block_container and has_node("BlockContainer/Icon"):
			block_label.text = "%d" % stats.block
		else:
			block_label.text = "Block: %d" % stats.block
			
	if block_container:
		block_container.visible = should_show_block
	elif block_label:
		block_label.visible = should_show_block
		
	if has_node("ManaLabel") and "mana" in stats:
		var mana_label = get_node("ManaLabel") as Label
		if mana_label:
			var max_mana_val = stats.max_mana if "max_mana" in stats else 3
			mana_label.text = "Mana: %d / %d" % [stats.mana, max_mana_val]
