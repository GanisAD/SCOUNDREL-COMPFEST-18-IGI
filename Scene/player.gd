extends Node2D
class_name Player

# Menampung data runtime pertarungan yang disuntikkan oleh combat.gd
var character_stats: CharacterStats : set = set_character_stats

# Referensi ke komponen UI internal milik Player (buat di editor jika belum ada)
@onready var health_bar: ProgressBar = $StatsUI/HealthBar
@onready var health_label: Label = $StatsUI/HealthLabel
@onready var block_label: Label = $StatsUI/BlockLabel
@onready var block_icon: TextureRect = $StatsUI/BlockIcon
@onready var sprite_2d: Sprite2D = $Sprite2D

# Setter otomatis: Begitu combat.gd menyuntikkan data, Player langsung mendengarkan sinyalnya
func set_character_stats(value: CharacterStats) -> void:
	character_stats = value
	
	# Mencegah double-connection sinyal stats_changed bawaan resource
	if character_stats and not character_stats.stats_changed.is_connected(update_stats):
		character_stats.stats_changed.connect(update_stats)
		
	if is_inside_tree():
		_initialize_player_visuals()

func _ready() -> void:
	_initialize_player_visuals()

# Setup visual awal pertarungan (gambar sprite karakter)
func _initialize_player_visuals() -> void:
	if not character_stats:
		return
	if character_stats.art:
		sprite_2d.texture = character_stats.art
	update_stats()

# Fungsi re-render UI HP & Block secara realtime setiap kali resource berubah
func update_stats() -> void:
	if not character_stats or not is_inside_tree():
		return
		
	# Update bar nyawa pemain
	health_bar.max_value = character_stats.max_health
	health_bar.value = character_stats.health
	health_label.text = str(character_stats.health) + "/" + str(character_stats.max_health)
	
	# Update sistem Block/Shield mekanik Slay the Spire
	if character_stats.block > 0:
		block_label.text = str(character_stats.block)
		block_label.show()
		if block_icon: block_icon.show()
	else:
		block_label.hide()
		if block_icon: block_icon.hide()
		
	# Cek kondisi trigger kematian untuk mengabarkan orkestrator (combat.gd)
	if character_stats.health <= 0:
		Events.player_died.emit()
		queue_free()
