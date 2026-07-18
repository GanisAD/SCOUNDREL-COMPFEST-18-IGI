class_name CardDraggingState
extends CardState

const DRAG_MINIMUM_THRESHOLD := 0.05
var minimum_drag_time_elapsed := false

func enter() -> void:
	# Ambil referensi UI Layer global (menggunakan grup scene yang sudah disiapkan)
	var ui_layer := get_tree().get_first_node_in_group("ui_layer")
	if ui_layer:
		# Lepaskan kartu dari kontainer tangan agar posisinya bisa bebas melayang
		card_ui.reparent(ui_layer)
		
	card_ui.state.text = "DRAGGING"
	card_ui.color.color = Color.MEDIUM_PURPLE
	
	# Keamanan Input: Gunakan SceneTree Timer dengan flag false (agar berhenti saat game dipause)
	minimum_drag_time_elapsed = false
	get_tree().create_timer(DRAG_MINIMUM_THRESHOLD, false).timeout.connect(
		func(): minimum_drag_time_elapsed = true
	)

# DI DALAM card_dragging_state.gd
func on_input(event: InputEvent) -> void:
	# 1. Update posisi kartu mengikuti kursor
	if event is InputEventMouseMotion:
		card_ui.global_position = card_ui.get_global_mouse_position() - card_ui.pivot_offset
		
	# 2. Deteksi Batal (Klik Kanan)
	if event.is_action_pressed("right_click"):
		transition_requested.emit(self.state, CardState.State.BASE)
		
	# 3. Deteksi Lepas Klik Kiri
	elif event.is_action_released("left_click"):
		transition_requested.emit(self.state, CardState.State.RELEASED)
