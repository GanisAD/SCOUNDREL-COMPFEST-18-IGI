class_name Hand
extends HBoxContainer

# TAMBAHAN: Tempatkan scene CardUI.tscn di slot ini melalui Inspector Godot
@export var card_ui_scene: PackedScene 

var cards_played_this_turn: int = 0

func _ready() -> void:
	Events.card_played.connect(_on_card_played)
	Events.card_drag_started.connect(_on_card_drag_started)
	Events.card_drag_ended.connect(_on_card_drag_ended)
	
	# Tetap pertahankan ini jika Anda menaruh kartu placeholder langsung di editor untuk testing
	for child in get_children():
		var card_ui := child as CardUI
		if card_ui:
			card_ui.reparent_requested.connect(_on_card_reparent_requested)

func _on_card_played(_card: Card) -> void:
	cards_played_this_turn += 1

func _on_card_reparent_requested(card_ui: CardUI) -> void:
	card_ui.reparent(self)
	var new_index: int = card_ui.original_index - cards_played_this_turn
	new_index = clampi(new_index, 0, get_child_count() - 1)
	move_child.call_deferred(card_ui, new_index)

# =========================================================
# FUNGSI BARU: MENANGANI KARTU YANG MASUK DI TENGAH PERMAINAN
# =========================================================
func add_card_to_hand(card_data: Card) -> void:
	if not card_ui_scene:
		push_error("Hand: card_ui_scene belum di-assign di Inspector!")
		return
		
	# 1. Lahirkan instance UI kartu baru
	var new_card_ui = card_ui_scene.instantiate() as CardUI
	if not new_card_ui:
		return
		
	# 2. SEGERA HUBUNGKAN SINYALNYA secara dinamis sebelum masuk Tree
	new_card_ui.reparent_requested.connect(_on_card_reparent_requested)
	
	# 3. Masukkan ke dalam container tangan ini
	add_child(new_card_ui)
	
	# 4. Suntikkan data resource kartunya
	new_card_ui.card = card_data
	
	# 5. Kalkulasi indeks awal yang adil
	# Kita tambahkan dengan 'cards_played_this_turn' agar saat di-cancel nanti,
	# rumusan pengurangan di '_on_card_reparent_requested' menghasilkan angka indeks fisik yang pas.
	new_card_ui.original_index = new_card_ui.get_index() + cards_played_this_turn

# ==========================================
# RE-HOVER ISOLATION (KODE ANDA YANG SUDAH BAGUS)
# ==========================================
func _on_card_drag_started(active_card: CardUI) -> void:
	for card_ui in get_children():
		if card_ui != active_card:
			card_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_card_drag_ended(_active_card: CardUI) -> void:
	for card_ui in get_children():
		card_ui.mouse_filter = Control.MOUSE_FILTER_STOP
