class_name CardUI
extends Control

# ==========================================
# SIGNAL KOMUNIKASI
# ==========================================
# Sinyal ini tetap dipertahankan karena digunakan oleh CardBaseState/CardDraggingState
# untuk meminta parent (HBoxContainer tangan) melakukan lepas/pasang hierarki.
signal reparent_requested(card_ui: CardUI)

# ==========================================
# INJEKSI DATA RESOURCE
# ==========================================
@export var card: Card : set = _set_card

var original_index: int = 0
var targets: Array[Area2D] = []

# ==========================================
# REFERENSI NODE VISUAL
# ==========================================
@onready var cost_label: Label = $CostLabel
@onready var name_label: Label = $NameLabel
@onready var description_label: RichTextLabel = $DescriptionLabel
@onready var icon_rect: TextureRect = $IconRect
@onready var drop_point_detector: Area2D = $DropPointDetector
@onready var card_state_machine: CardStateMachine = $CardStateMachine

# Menambahkan variabel pembantu (opsional) yang sering diakses oleh state anak
@onready var color: ColorRect = $CardFrame# Jika ada komponen visual warna untuk debug
@onready var state: Label = $StateLabel # Jika ada komponen visual text untuk debug

func _ready() -> void:
	original_index = get_index()

	# 1. PERBAIKAN KRUSIAL: Inisialisasi State Machine Anda!
	card_state_machine.init(self)

	# 2. PERBAIKAN KRUSIAL: Hubungkan sinyal radar DropPointDetector
	drop_point_detector.area_entered.connect(_on_drop_point_detector_area_entered)
	drop_point_detector.area_exited.connect(_on_drop_point_detector_area_exited)

	# 3. Hubungkan sinyal interaksi mouse UI bawaan ke fungsi routing
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)

# ==========================================
# FUNGSI PEMBARUAN VISUAL
# ==========================================
func _set_card(value: Card) -> void:
	card = value
	if not is_node_ready():
		await ready
	_update_ui()

func _update_ui() -> void:
	if not card:
		return
		
	cost_label.text = str(card.cost)
	name_label.text = card.name
	description_label.text = card.description
	
	if card.icon:
		icon_rect.texture = card.icon

# ========================================================
# MECHANISM: ROUTING INPUT KE STATE MACHINE
# ========================================================

func _input(event: InputEvent) -> void:
	card_state_machine.on_input(event)

func _on_gui_input(event: InputEvent) -> void:
	card_state_machine.on_gui_input(event)

func _on_mouse_entered() -> void:
	card_state_machine.on_mouse_entered()

func _on_mouse_exited() -> void:
	card_state_machine.on_mouse_exited()

# ========================================================
# LOGIKA RADAR DETEKSI AREA (DROP POINT DETECTOR)
# ========================================================

func _on_drop_point_detector_area_entered(area: Area2D) -> void:
	if not targets.has(area):
		targets.append(area)

func _on_drop_point_detector_area_exited(area: Area2D) -> void:
	targets.erase(area)
