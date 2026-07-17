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

func on_input(event: InputEvent) -> void:
	var mouse_motion := event is InputEventMouseMotion
	# Jika dilepas atau di-klik ulang tombol kiri mouse
	var confirm := event.is_action_released("left_click") or event.is_action_pressed("left_mouse")
	
	# 1. Update posisi kartu secara presisi mengikuti kursor mouse saat bergerak
	if mouse_motion:
		card_ui.global_position = card_ui.get_global_mouse_position() - card_ui.pivot_offset
		
	# 2. Pembatalan: Jika klik kanan ditekan, batalkan drag dan kembalikan ke BASE
	if event.is_action_pressed("right_mouse"):
		transition_requested.emit(self.state, CardState.State.BASE)
		
	# 3. Konfirmasi: Jika tombol kiri dilepas DAN ambang batas waktu aman terpenuhi
	elif event.is_action_released("left_click"):
		# Tandai event sebagai handled agar input tidak bocor ke game/kartu lain
		#get_viewport().set_input_as_handled()
		# Pindah ke status RELEASED untuk pengecekan akhir
		transition_requested.emit(self.state, CardState.State.RELEASED)
