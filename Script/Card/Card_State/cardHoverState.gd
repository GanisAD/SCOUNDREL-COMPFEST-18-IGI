class_name CardHoverState
extends CardState

# Tentukan seberapa tinggi kartu akan naik ke atas (dalam piksel)
const HOVER_LIFT_AMOUNT := -120.0 

var hover_tween: Tween
var is_animating: bool = false

func enter() -> void:
	card_ui.state.text = "HOVER"
	
	# Biarkan pivot tetap di ZERO (Top-Left) agar stabil
	card_ui.pivot_offset = Vector2.ZERO
	card_ui.z_index = 10
	
	# Matikan interaksi mouse saat kartu membesar agar tidak terjadi efek naik-turun/flicker
	is_animating = true
	card_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if hover_tween and hover_tween.is_valid():
		hover_tween.kill()
		
	hover_tween = card_ui.create_tween().set_parallel(true)
	hover_tween.tween_property(card_ui, "scale", Vector2(1.2, 1.2), 0.1)
	# Mainkan sumbu Y saja, biarkan X tetap dikontrol HBoxContainer
	hover_tween.tween_property(card_ui, "position:y", HOVER_LIFT_AMOUNT, 0.1)
	hover_tween.finished.connect(_on_hover_tween_finished)
	
	if card_ui.has_method("show_tooltip"):
		card_ui.show_tooltip()

func _on_hover_tween_finished() -> void:
	is_animating = false
	card_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Setelah animasi selesai, periksa apakah kursor masih di atas kartu
	if DisplayServer.get_name() != "headless" and not _is_mouse_over_card():
		transition_requested.emit(self.state, CardState.State.BASE)
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		# Jika pemain menahan klik kiri saat animasi membesar selesai
		card_ui.drag_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self.state, CardState.State.CLICKED)

func exit() -> void:
	if hover_tween and hover_tween.is_valid():
		hover_tween.kill()
		
	card_ui.mouse_filter = Control.MOUSE_FILTER_STOP
	is_animating = false
	
	if card_ui.has_method("hide_tooltip"):
		card_ui.hide_tooltip()

func on_mouse_exited() -> void:
	if is_animating:
		return
	transition_requested.emit(self.state, CardState.State.BASE)

func on_gui_input(event: InputEvent) -> void:
	if is_animating:
		return
	if event.is_action_pressed("left_click"):
		card_ui.drag_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self.state, CardState.State.CLICKED)

func _is_mouse_over_card() -> bool:
	if not card_ui or not card_ui.is_inside_tree():
		return false
	var mouse_pos := card_ui.get_global_mouse_position()
	var card_rect := Rect2(
		card_ui.global_position,
		Vector2(card_ui.size.x * card_ui.scale.x, card_ui.size.y * card_ui.scale.y + abs(HOVER_LIFT_AMOUNT))
	)
	return card_rect.has_point(mouse_pos)
