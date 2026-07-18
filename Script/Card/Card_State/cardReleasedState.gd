class_name CardReleasedState
extends CardState

var played := false

func enter() -> void:
	played = false
	card_ui.state.text = "RELEASED"
	card_ui.color.color = Color.BROWN
	
	_evaluate_release.call_deferred()
	

func _evaluate_release() -> void:
	# 1. Ambil data resource kartu yang sedang berinteraksi
	var card_data: Card = card_ui.card
	if not card_data:
		_return_to_base()
		return
		
	# 2. Siapkan penampung hasil validasi
	var is_valid_play := false
	var final_targets: Array[Node] = []
	
	# 3. MATRIKS VALIDASI TARGET (Mengacu pada Enum Target di CardData.gd)
	match card_data.target:
		Card.Target.SELF:
			# Kartu buff/defend diri sendiri sah jika dilepas di area drop umum layar
			if _is_dropped_in_area("CardDropArea"):
				is_valid_play = true
				var player = get_tree().get_first_node_in_group("player")
				if player: final_targets.append(player)
				
		Card.Target.SINGLE_ENEMY:
			# Harus mengenai spesifik node musuh yang valid (bukan area kosong)
			var enemy = _get_enemy_from_targets()
			if enemy:
				is_valid_play = true
				final_targets.append(enemy)
				
		Card.Target.ALL_ENEMIES:
			# Sah jika dilepas di area drop umum, otomatis menarik semua musuh yang hidup
			if _is_dropped_in_area("CardDropArea"):
				is_valid_play = true
				var active_enemies = get_tree().get_nodes_in_group("enemies")
				for enemy in active_enemies:
					final_targets.append(enemy)
					
		Card.Target.EVERYONE:
			# Sah jika di area drop umum, menarik player DAN semua musuh
			if _is_dropped_in_area("CardDropArea"):
				is_valid_play = true
				var player = get_tree().get_first_node_in_group("player")
				if player: final_targets.append(player)
				var active_enemies = get_tree().get_nodes_in_group("enemies")
				for enemy in active_enemies:
					final_targets.append(enemy)

	# 4. EKSEKUSI LOGIKA JIKA PLAY DINYATAKAN VALID
	if is_valid_play:
		played = true
		
		# Jalankan efek logic mekanik kartu (Data-Driven)
		var player_node = get_tree().get_first_node_in_group("player")
		card_data.apply_effects(final_targets, player_node)
		
		Events.card_played.emit(card_data)
		
		# ========================================================
		# PENANGANAN MEKANIK HANGUS (EXHAUST)
		# ========================================================
		if card_data.exhaust:
			print("Mekanik HANGUS terpicu untuk kartu: ", card_data.name)
			# Opsional: Pancarkan sinyal ke global tumpukan hangus jika tim butuh melacaknya
			# Events.card_exhausted.emit(card_data)
			
			# Hapus total Node kartu dari memori layar secara permanen untuk battle ini
			card_ui.queue_free()
		else:
			# Jika tidak hangus, biarkan Node dikosongkan/dihapus oleh Hand Controller 
			# atau dipindah secara visual menuju Discard Pile Anda
			card_ui.queue_free() 
			
	else:
		# Jika melanggar aturan target (misal kartu single-target dilepas di area kosong),
		# paksa kartu pulang kembali ke tangan pemain.
		_return_to_base()

func _return_to_base() -> void:
	transition_requested.emit(self.state, CardState.State.BASE)

# ========================================================
# FUNGSI INTERNAL PEMBANTU VALIDASI (HELPER FUNCTIONS)
# ========================================================

# Mengecek apakah radar kartu mendeteksi nama node drop area umum
func _get_enemy_from_targets() -> Node:
	for area in card_ui.targets:
		if is_instance_valid(area) and area is Area2D:
			if area.is_in_group("enemies"):
				return area
	return null

func _is_dropped_in_area(area_name: String) -> bool:
	for area in card_ui.targets:
		if is_instance_valid(area) and "name" in area:
			if area.name == area_name:
				return true
	return false
