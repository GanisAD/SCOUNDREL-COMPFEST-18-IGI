class_name CardHoverState
extends CardState

# Tentukan seberapa tinggi kartu akan naik ke atas (dalam piksel)
const HOVER_LIFT_AMOUNT := -120.0 

func enter() -> void:
	card_ui.state.text = "HOVER"
	
	# Biarkan pivot tetap di ZERO (Top-Left) agar stabil
	card_ui.pivot_offset = Vector2.ZERO
	
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(card_ui, "scale", Vector2(1.2, 1.2), 0.1)
	# Mainkan sumbu Y saja, biarkan X tetap dikontrol HBoxContainer
	tween.tween_property(card_ui, "position:y", HOVER_LIFT_AMOUNT, 0.1)
	
	card_ui.z_index = 10
	
	if card_ui.has_method("show_tooltip"):
		card_ui.show_tooltip()

func exit() -> void:
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(card_ui, "scale", Vector2.ONE, 0.1)
	# Turunkan kembali sumbu Y ke posisi 0 horizontal kontainer
	tween.tween_property(card_ui, "position:y", 0.0, 0.1)
	
	card_ui.z_index = 0
	
	if card_ui.has_method("hide_tooltip"):
		card_ui.hide_tooltip()

func on_mouse_exited() -> void:
	transition_requested.emit(self.state, CardState.State.BASE)

func on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		card_ui.pivot_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self.state, CardState.State.CLICKED)
