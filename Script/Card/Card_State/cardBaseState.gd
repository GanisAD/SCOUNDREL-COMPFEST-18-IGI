class_name CardBaseState
extends CardState

var base_tween: Tween

func enter() -> void:
	if not card_ui.is_node_ready():
		await card_ui.ready
		
	# Kembalikan jangkar ke default
	card_ui.pivot_offset = Vector2.ZERO
	card_ui.rotation = 0.0
	card_ui.drop_point_detector.monitoring = false
	card_ui.z_index = 0
	card_ui.state.text = "BASE"
	
	if base_tween and base_tween.is_valid():
		base_tween.kill()
		
	# Animasi halus kembali ke skala 1.0 dan posisi y 0.0 jika kartu sebelumnya terangkat/membesar
	if card_ui.scale != Vector2.ONE or card_ui.position.y != 0.0:
		base_tween = card_ui.create_tween().set_parallel(true)
		base_tween.tween_property(card_ui, "scale", Vector2.ONE, 0.1)
		base_tween.tween_property(card_ui, "position:y", 0.0, 0.1)
	else:
		card_ui.scale = Vector2.ONE
		card_ui.position.y = 0.0

func exit() -> void:
	if base_tween and base_tween.is_valid():
		base_tween.kill()

func on_mouse_entered() -> void:
	# Jika mouse masuk saat kartu sedang diam, pindah ke status HOVER
	transition_requested.emit(self.state, CardState.State.HOVER)

func on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		card_ui.drag_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self.state, CardState.State.CLICKED)
