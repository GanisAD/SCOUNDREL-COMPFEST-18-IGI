class_name BattleUI
extends CanvasLayer

# --- REFERENSI NODE ---
# Alih-alih merujuk ke Label spesifik, kita merujuk ke komponen StatsUI generik
@onready var player_stats_ui: StatsUI = $PlayerStatsUI
#@onready var end_turn_button: Button = $EndTurnButton

# (Opsional) Referensi untuk komponen UI lainnya di masa depan
# @onready var mana_ui: Control = $ManaUI
# @onready var draw_pile_label: Label = $DrawPileButton/Label
# @onready var discard_pile_label: Label = $DiscardPileButton/Label

#func _ready() -> void:
	# Hubungkan sinyal klik tombol End Turn
	#if end_turn_button:
		#end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	
	# Hubungkan sinyal dari Event Bus global (jika kamu menggunakannya)
	# Events.player_turn_started.connect(_on_player_turn_started)

# --- INISIALISASI ---

# Fungsi ini akan dipanggil oleh BattleManager (battle.gd) saat awal permainan
# untuk memasukkan data karakter pemain ke dalam UI.
func initialize_player(character_stats: CharacterStats) -> void:
	# Kita cukup "melempar" datanya ke komponen StatsUI.
	# Komponen StatsUI yang akan mengurus pembaruan teks HP dan Block!
	if player_stats_ui:
		player_stats_ui.stats = character_stats
		
	# Jika nanti ada mana, bisa juga disuntikkan di sini
	# if mana_ui: mana_ui.stats = character_stats

# --- MANAJEMEN GILIRAN (TURN MANAGEMENT) ---

#func _on_end_turn_button_pressed() -> void:
	## 1. Matikan tombol segera setelah ditekan untuk mencegah pemain melakukan spam klik
	#end_turn_button.disabled = true
	#
	## 2. Pancarkan sinyal ke sistem global bahwa pemain telah mengakhiri gilirannya.
	## Ini akan ditangkap oleh Battle Manager atau Player Handler untuk memulai fase buang kartu (discard)
	## dan memulai antrean serangan Enemy Handler.
	#Events.player_turn_ended.emit()
#
#func _on_player_turn_started() -> void:
	## Saat Enemy selesai menyerang dan giliran kembali ke Player, aktifkan lagi tombolnya
	#if end_turn_button:
		#end_turn_button.disabled = false
