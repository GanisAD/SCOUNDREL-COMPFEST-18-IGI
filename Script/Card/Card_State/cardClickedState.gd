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
	elif event.is_action_released("left_click") or event.is_action_pressed("right_click"):
		card_ui.drop_point_detector.monitoring = false
		transition_requested.emit(self.state, CardState.State.BASE)
