class_name CardHoverState
extends CardState

# Tentukan seberapa tinggi kartu akan naik ke atas (dalam piksel)
const HOVER_LIFT_AMOUNT := -30.0 

func enter() -> void:
	card_ui.state.text = "HOVER"
	#card_ui.color.color = Color.GREEN_YELLOW
	
	# 1. VISUAL POLISH: Buat parallel tween agar perbesaran dan pergeseran jalan bersamaan
	var tween := get_tree().create_tween().set_parallel(true)
	
	# Efek Membesar
	tween.tween_property(card_ui, "scale", Vector2(1.2, 1.2), 0.1)
	
	# Efek Bergeser ke Atas (Nilai negatif pada sumbu Y berarti bergerak ke atas layar)
	tween.tween_property(card_ui, "position:y", HOVER_LIFT_AMOUNT, 0.1)
	
	# 2. HIERARCHY FIX: Pastikan digambar di paling depan
	card_ui.z_index = 10
	
	# 3. TOOLTIP
	if card_ui.has_method("show_tooltip"):
		card_ui.show_tooltip()

func exit() -> void:
	# 1. Kembalikan visual ke default secara halus
	var tween := get_tree().create_tween().set_parallel(true)
	
	# Kembalikan skala ke normal
	tween.tween_property(card_ui, "scale", Vector2.ONE, 0.1)
	
	# Kembalikan posisi Y ke koordinat dasar kontainer (0)
	tween.tween_property(card_ui, "position:y", 0.0, 0.1)
	
	# 2. Kembalikan z_index
	card_ui.z_index = 0
	
	# 3. TOOLTIP
	if card_ui.has_method("hide_tooltip"):
		card_ui.hide_tooltip()

func on_mouse_exited() -> void:
	transition_requested.emit(self.state, CardState.State.BASE)

func on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		card_ui.pivot_offset = card_ui.get_global_mouse_position() - card_ui.global_position
		transition_requested.emit(self.state, CardState.State.CLICKED)
