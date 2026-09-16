class_name CardBaseState
extends CardState

func enter() -> void:
	if not card_ui.is_node_ready():
		await card_ui.ready
		
	# Kembalikan jangkar ke default
	card_ui.pivot_offset = Vector2.ZERO
	
	card_ui.rotation = 0.0
	card_ui.scale = Vector2.ONE
	
	card_ui.position.y = 0.0
	
	card_ui.state.text = "BASE"
func on_mouse_entered() -> void:
	# Jika mouse masuk saat kartu sedang diam, pindah ke status HOVER
	transition_requested.emit(self.state, CardState.State.HOVER)
