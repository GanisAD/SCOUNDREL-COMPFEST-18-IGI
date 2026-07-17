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

func on_gui_input(event: InputEvent) -> void:
	# Jika pemain menekan tombol klik kiri mouse pada kartu
	if event.is_action_pressed("left_click"):
		# Set offset titik kursor pada kartu agar tidak melompat ke pojok kiri atas
		card_ui.pivot_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		# Minta transisi ke status CLICKED
		transition_requested.emit(self.state, CardState.State.CLICKED)
