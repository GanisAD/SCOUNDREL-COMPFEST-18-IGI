class_name CardClickedState
extends CardState

func enter() -> void:
	# Perbarui info teks debug
	card_ui.state.text = "CLICKED"
	#card_ui.color.color = Color.ORANGE
	
	# Aktifkan monitoring Area2D kartu untuk mendeteksi DropArea di battlefield
	card_ui.drop_point_detector.monitoring = true

func on_input(event: InputEvent) -> void:
	# Jika pemain mulai menggerakkan mouse (Mouse Motion) setelah klik
	if event is InputEventMouseMotion:
		# Transisikan langsung ke status DRAGGING
		transition_requested.emit(self.state, CardState.State.DRAGGING)
	elif event.is_action_released("left_click"):
		card_ui.drop_point_detector.monitoring = false
		var mouse_pos := card_ui.get_global_mouse_position()
		var card_rect := Rect2(card_ui.global_position, card_ui.size * card_ui.scale)
		if card_rect.has_point(mouse_pos):
			transition_requested.emit(self.state, CardState.State.HOVER)
		else:
			transition_requested.emit(self.state, CardState.State.BASE)
	elif event.is_action_pressed("right_click"):
		card_ui.drop_point_detector.monitoring = false
		transition_requested.emit(self.state, CardState.State.BASE)
