## AudioManager (Autoload / Singleton Pengelola Audio)
##
## Bertanggung jawab mengelola pemutaran Background Music (BGM), Sound Effect (SFX),
## dan feedback audio UI secara terpusat untuk proyek ALTAR-52.
##
## Sistem ini secara otomatis mendengarkan sinyal dari EventBus (Events), sehingga Sound Designer
## dapat mengaitkan file audio (.wav/.ogg) langsung melalui Inspector tanpa harus memodifikasi
## logika gameplay di script tempur atau kartu.
class_name AudioManager
extends Node  

# ==========================================
# KONFIGURASI AUDIO STREAM DI INSPECTOR
# ==========================================

@export_group("Card Audio Cues")
## Suara saat mouse hover di atas kartu.
##@export var sfx_card_hover: AudioStream
## Suara saat kartu mulai ditarik (drag).
@export var sfx_card_drag_start: AudioStream
## Suara saat tarikan kartu dibatalkan / dilepas tanpa target.
@export var sfx_card_drag_cancel: AudioStream
## Suara saat kartu berhasil dimainkan di battlefield.
@export var sfx_card_played: AudioStream
## Suara saat kartu ditarik dari deck ke tangan.
@export var sfx_card_draw: AudioStream
## Suara saat kartu dibuang ke discard pile.
@export var sfx_card_discard: AudioStream

@export_group("Combat Audio Cues")
## Suara saat giliran pemain dimulai.
@export var sfx_turn_player_start: AudioStream
## Suara saat giliran musuh dimulai.
@export var sfx_turn_enemy_start: AudioStream
## Suara saat seluruh musuh dikalahkan (Kemenangan).
@export var sfx_victory: AudioStream
## Suara saat karakter pemain tewas (Kekalahan).
@export var sfx_defeat: AudioStream

@export_group("UI Audio Cues")
## Suara klik tombol standar antarmuka.
@export var sfx_button_click: AudioStream

@export_group("Exploration Audio Cues")
## Suara SFX ketika berpindah lantai.
@export var sfx_elevator: AudioStream

@export_group("Exploration Fight Cues")
## Suara SFX ketika menggunakan kartu senjata.
@export var sfx_weapon: AudioStream

## Suara SFX ketika menggunakan kartu potion.
@export var sfx_potion: AudioStream

## Suara SFX ketika menggunakan kartu shiled.
@export var sfx_shield: AudioStream

## Suara SFX ketika menerima damage/memberikan damage.
@export var sfx_hit: AudioStream


# ==========================================
# NODE PEMUTAR AUDIO INTERNAL
# ==========================================
var _bgm_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE: int = 8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_players()
	_connect_event_bus()

## Menginisialisasi player untuk BGM dan pool player untuk SFX
func _setup_audio_players() -> void:
	# 1. Setup BGM Player
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	_bgm_player.bus = "BGM" if AudioServer.get_bus_index("BGM") != -1 else "Master"
	add_child(_bgm_player)
	
	# 2. Setup SFX Player Pool (Mencegah suara terpotong saat banyak aksi bersamaan)
	for i in range(SFX_POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		player.bus = "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"
		add_child(player)
		_sfx_players.append(player)

## Menghubungkan AudioManager ke EventBus global
func _connect_event_bus() -> void:
	if not Engine.has_singleton("Events") and not is_instance_valid(Events):
		return
		
	##Events.card_hovered.connect(func(_card_ui): play_sfx(sfx_card_hover, randf_range(0.95, 1.05)))
	Events.card_drag_started.connect(func(_card_ui): play_sfx(sfx_card_drag_start))
	Events.card_drag_ended.connect(func(_card_ui): play_sfx(sfx_card_drag_cancel))
	Events.card_played.connect(func(_card): play_sfx(sfx_card_played))
	Events.card_drawn.connect(func(): play_sfx(sfx_card_draw))
	Events.card_discarded.connect(func(): play_sfx(sfx_card_discard))
	
	Events.player_turn_started.connect(func(): play_sfx(sfx_turn_player_start))
	Events.enemy_turn_started.connect(func(): play_sfx(sfx_turn_enemy_start))
	
	Events.player_died.connect(func(): play_sfx(sfx_defeat))
	Events.combat_victory.connect(func(): play_sfx(sfx_victory))
	Events.ui_button_clicked.connect(func(): play_sfx(sfx_button_click))

	Events.floor_changed.connect(func(_current_floor: int, _max_floor: int): play_sfx(sfx_elevator))
	
	Events.weapon_used.connect(func(): play_sfx(sfx_weapon))
	Events.potion_used.connect(func(): play_sfx(sfx_potion))
	Events.shield_used.connect(func(): play_sfx(sfx_shield))
	Events.hit_taken.connect(func(): play_sfx(sfx_hit))
	
		
# ==========================================
# FUNGSI PUBLIK (API AUDIO)
# ==========================================

## Memutar sound effect 2D non-spatial menggunakan pool audio.
## [param stream]: Resource file suara yang ingin diputar (.wav atau .ogg).
## [param pitch_scale]: Modulasi nada suara (gunakan variasi pitch kecil misal 0.9 - 1.1 agar suara tidak monoton).
## [param volume_db]: Penyesuaian desibel suara.
func play_sfx(stream: AudioStream, pitch_scale: float = 1.0, volume_db: float = 0.0) -> void:
	if not stream:
		return
		
	# Cari player di dalam pool yang sedang menganggur
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.pitch_scale = pitch_scale
			player.volume_db = volume_db
			player.play()
			return
			
	# Jika semua player sedang sibuk, pinjam player pertama
	var fallback_player = _sfx_players[0]
	fallback_player.stream = stream
	fallback_player.pitch_scale = pitch_scale
	fallback_player.volume_db = volume_db
	fallback_player.play()

## Memutar musik latar belakang (BGM).
## [param stream]: Resource file musik.
## [param crossfade_time]: Durasi transisi perpindahan musik (dalam detik).
func play_bgm(stream: AudioStream, crossfade_time: float = 0.8) -> void:
	if not stream or _bgm_player.stream == stream:
		return
		
	if crossfade_time > 0 and _bgm_player.playing:
		var tween = create_tween()
		tween.tween_property(_bgm_player, "volume_db", -40.0, crossfade_time)
		tween.tween_callback(func():
			_bgm_player.stream = stream
			_bgm_player.volume_db = 0.0
			_bgm_player.play()
		)
	else:
		_bgm_player.stream = stream
		_bgm_player.volume_db = 0.0
		_bgm_player.play()

## Menghentikan BGM yang sedang berjalan secara halus (fade out).
func stop_bgm(fade_time: float = 1.0) -> void:
	if not _bgm_player.playing:
		return
	var tween = create_tween()
	tween.tween_property(_bgm_player, "volume_db", -40.0, fade_time)
	tween.tween_callback(_bgm_player.stop)
