class_name CardUI
extends Control

# ==========================================
# SIGNAL KOMUNIKASI
# ==========================================
# Signal ini akan didengarkan oleh Card State Machine
# untuk mengubah status kartu (Base, Clicked, Dragging, Aiming)
signal hover_started(card_ui: CardUI)
signal hover_ended(card_ui: CardUI)
signal clicked(card_ui: CardUI)
signal released(card_ui: CardUI)

signal reparent_requested(card_ui: CardUI)

# ==========================================
# INJEKSI DATA RESOURCE
# ==========================================
# Kita menggunakan setter fungsi untuk otomatis memperbarui UI
# setiap kali data 'card' baru disuntikkan ke node ini.
@export var card: Card : set = _set_card

var original_index: int = 0

# ==========================================
# REFERENSI NODE VISUAL
# ==========================================
@onready var cost_label: Label = $CostLabel
@onready var name_label: Label = $NameLabel
@onready var description_label: RichTextLabel = $DescriptionLabel
@onready var icon_rect: TextureRect = $IconRect
@onready var drop_point_detector: Area2D = $DropPointDetector

func _ready() -> void:
	original_index = get_index()

	# Pastikan node bisa merespons interaksi mouse
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

# ==========================================
# FUNGSI PEMBARUAN VISUAL
# ==========================================
func _set_card(value: Card) -> void:
	card = value
	# Jika node belum siap di scene tree, tunggu sampai _ready terpanggil
	if not is_node_ready():
		await ready
	_update_ui()

func _update_ui() -> void:
	if not card:
		return
		
	# Mengisi data visual berdasarkan resource
	cost_label.text = str(card.cost)
	name_label.text = card.name
	description_label.text = card.description
	
	if card.icon:
		icon_rect.texture = card.icon

# ==========================================
# PENDETEKSI INPUT PENGGUNA
# ==========================================
func _on_gui_input(event: InputEvent) -> void:
	# Kita asumsikan "left_click" sudah di-setup di Input Map Godot (Project Settings)
	if event.is_action_pressed("left_click"):
		clicked.emit(self)
	elif event.is_action_released("left_click"):
		released.emit(self)

func _on_mouse_entered() -> void:
	hover_started.emit(self)

func _on_mouse_exited() -> void:
	hover_ended.emit(self)
