class_name CardClickedState
extends CardState

func enter() -> void:
	# Perbarui info teks debug
	card_ui.state.text = "CLICKED"
	card_ui.color.color = Color.ORANGE
	
	# Aktifkan monitoring Area2D kartu untuk mendeteksi DropArea di battlefield
	card_ui.drop_point_detector.monitoring = true

func on_input(event: InputEvent) -> void:
	# Jika pemain mulai menggerakkan mouse (Mouse Motion) setelah klik
	if event is InputEventMouseMotion:
		# Transisikan langsung ke status DRAGGING
		transition_requested.emit(self.state, CardState.State.DRAGGING)
		
