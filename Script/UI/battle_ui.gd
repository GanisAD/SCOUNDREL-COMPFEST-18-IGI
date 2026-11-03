## Controller HUD utama untuk antarmuka pertempuran (Combat).
## Bertanggung jawab mengelola banner giliran, tombol End Turn,
## dan menghubungkan data CharacterStats pemain ke komponen PlayerStatsUI,
## serta menghubungkan InventoryData ke PotionContainer dan DebuffContainer.
class_name BattleUI
extends CanvasLayer

# --- REFERENSI NODE ---
## Label banner animasi pergantian giliran (PLAYER TURN / ENEMY TURN).
@onready var turn_label: Label = $TurnLabel
## Komponen HUD penampil HP dan Block pemain.
@onready var player_stats_ui: StatsUI = $PlayerStatsUI
## Tombol untuk mengakhiri giliran pemain.
@onready var end_turn_button: Button = $EndTurnButton
## Komponen Dynamic HBox untuk Potion
@onready var potion_container: PotionContainer = get_node_or_null("PotionContainer")
## Komponen Dynamic HBox untuk Debuff
@onready var debuff_container: DebuffContainer = get_node_or_null("DebuffContainer")

# (Opsional) Referensi untuk komponen UI lainnya di masa depan
# @onready var mana_ui: Control = $ManaUI
# @onready var draw_pile_label: Label = $DrawPileButton/Label
# @onready var discard_pile_label: Label = $DiscardPileButton/Label

func _ready() -> void:
	add_to_group("ui_layer")
	
	# Hubungkan sinyal klik tombol End Turn
	if end_turn_button:
		end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	
	# Hubungkan sinyal dari Event Bus global (jika tersedia)
	var events = get_node_or_null("/root/Events")
	if events and events.has_signal("player_turn_started"):
		events.player_turn_started.connect(_on_player_turn_started)

# --- INISIALISASI ---

# Fungsi ini dipanggil oleh BattleManager (combat.gd) saat awal pertempuran
# untuk memasukkan data karakter pemain ke dalam UI.
func initialize_player(character_stats: CharacterStats) -> void:
	# Memasukkan datanya ke komponen StatsUI.
	# Komponen StatsUI yang akan mengurus pembaruan teks HP dan Block!
	if player_stats_ui:
		player_stats_ui.stats = character_stats
		
	# Jika nanti ada mana, bisa juga disuntikkan di sini
	# if mana_ui: mana_ui.stats = character_stats

## Inisialisasi inventory pemain untuk PotionContainer dan DebuffContainer
func initialize_inventory(inventory_data: InventoryData) -> void:
	if potion_container:
		potion_container.inventory = inventory_data
	if debuff_container:
		debuff_container.inventory = inventory_data

func show_turn_banner(text: String) -> void:
	turn_label.text = text
	turn_label.modulate.a = 0.0
	turn_label.visible = true

	var tween = create_tween()
	# Animasi muncul (Fade in)
	tween.tween_property(turn_label, "modulate:a", 1.0, 0.3)
	# Diam sebentar
	tween.tween_interval(0.5)
	# Animasi menghilang (Fade out)
	tween.tween_property(turn_label, "modulate:a", 0.0, 0.3)

# --- MANAJEMEN GILIRAN (TURN MANAGEMENT) ---

func _on_end_turn_button_pressed() -> void:
	var events = get_node_or_null("/root/Events")
	if events and events.has_signal("ui_button_clicked"):
		events.ui_button_clicked.emit()
		
	# 1. Matikan tombol segera setelah ditekan untuk mencegah pemain melakukan spam klik
	end_turn_button.disabled = true
	
	# 2. Pancarkan sinyal ke sistem global bahwa pemain telah mengakhiri gilirannya.
	# Ini akan ditangkap oleh Battle Manager atau Player Handler untuk memulai fase buang kartu (discard)
	# dan memulai antrean serangan Enemy Handler.
	if events and events.has_signal("player_turn_ended"):
		events.player_turn_ended.emit()

func _on_player_turn_started() -> void:
	# Saat Enemy selesai menyerang dan giliran kembali ke Player, aktifkan lagi tombolnya
	if end_turn_button:
		end_turn_button.disabled = false
