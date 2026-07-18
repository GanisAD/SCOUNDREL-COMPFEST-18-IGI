class_name CardTargetSelector
extends Node2D

# ==========================================
# REFERENSI NODE
# ==========================================
@onready var arc_line: Line2D = $ArcLine
@onready var target_detector: Area2D = $Area2D

# ==========================================
# STATE VARIABLES
# ==========================================
var current_card: CardUI
var is_aiming: bool = false
var current_target: Node2D = null

func _ready() -> void:
	# Pastikan sistem mati/sembunyi saat game baru dimulai
	_stop_aiming()
	
	# Mendaftarkan diri ke "stasiun radio" Event Bus
	Events.card_aim_started.connect(_on_card_aim_started)
	Events.card_aim_ended.connect(_on_card_aim_ended)
	
	# Setup deteksi musuh
	target_detector.area_entered.connect(_on_enemy_entered)
	target_detector.area_exited.connect(_on_enemy_exited)

func _process(_delta: float) -> void:
	if not is_aiming:
		return
		
	# Update posisi detektor hitbox ke kursor mouse
	var mouse_pos = get_global_mouse_position()
	target_detector.global_position = mouse_pos
	
	# Gambar garis lengkung visual dari kartu ke mouse
	_update_arc_line(current_card.global_position, mouse_pos)

# ==========================================
# LOGIKA MENGGAMBAR GARIS
# ==========================================
func _update_arc_line(start_pos: Vector2, end_pos: Vector2) -> void:
	arc_line.clear_points()
	
	# Di tahap produksi, tim developer bisa mengganti ini dengan 
	# Kalkulasi Bezier Curve (Kurva lengkung) agar terlihat organik.
	# Untuk prototipe, garis lurus sudah cukup.
	arc_line.add_point(start_pos)
	arc_line.add_point(end_pos)

# ==========================================
# RESPON TERHADAP EVENT BUS
# ==========================================
func _on_card_aim_started(card_ui: CardUI) -> void:
	current_card = card_ui
	is_aiming = true
	arc_line.show()
	target_detector.monitoring = true

func _on_card_aim_ended(_card_ui: CardUI) -> void:
	_stop_aiming()

func _stop_aiming() -> void:
	is_aiming = false
	arc_line.hide()
	arc_line.clear_points()
	target_detector.monitoring = false
	current_target = null
	current_card = null

# ==========================================
# PENDETEKSI MUSUH
# ==========================================
func _on_enemy_entered(area: Area2D) -> void:
	# Jika Area2D musuh terdeteksi (asumsi musuh punya script "Enemy")
	current_target = area
	# Bisa tambahkan efek visual musuh menyala (highlight) di sini

func _on_enemy_exited(area: Area2D) -> void:
	if current_target == area:
		current_target = null
		# Matikan efek highlight musuh
