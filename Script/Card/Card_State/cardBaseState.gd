class_name CardBaseState
extends CardState

func enter() -> void:
	# Proteksi asinkronus jika Node UI belum sepenuhnya dimuat saat inisiasi
	if not card_ui.is_node_ready():
		await card_ui.ready
		
	# Minta tangan (HBoxContainer) untuk menarik/reparent kartu ini kembali ke layout
	card_ui.reparent_requested.emit(card_ui)
	
	card_ui.position = Vector2.ZERO
	card_ui.pivot_offset = Vector2.ZERO
	
	# Reset visual untuk kebutuhan debugging/state game
	card_ui.color.color = Color.WEB_GREEN
	card_ui.state.text = "BASE"

func on_mouse_entered() -> void:
	# Jika mouse masuk saat kartu sedang diam, pindah ke status HOVER
	transition_requested.emit(self.state, CardState.State.HOVER)
