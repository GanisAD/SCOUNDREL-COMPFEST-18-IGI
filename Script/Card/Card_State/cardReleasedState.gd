class_name CardReleasedState
extends CardState

var played := false

func enter() -> void:
	played = false
	card_ui.state.text = "RELEASED"
	card_ui.color.color = Color.DARK_RED
	
	# Cek apakah kartu mendeteksi DropArea di dalam array penampung targetnya
	if not card_ui.targets.is_empty():
		played = true
		# Tembakkan fungsi internal atau pemicu efek gameplay kartu di arena
		print("Kartu sukses dimainkan pada target: ", card_ui.targets)
		# NOTE: Di sini nantinya ditambahkan fungsi pemanggilan Effect System game Anda

func on_input(_event: InputEvent) -> void:
	# Jika kartu berhasil dimainkan, logika dikontrol oleh Battle/Hand controller, 
	# State Machine tidak perlu melakukan transisi manual lagi di sini.
	if played:
		return
		
	# Proteksi Kegagalan: Jika kartu dilepas di luar zona drop area, paksa kembali ke tangan (BASE)
	transition_requested.emit(self.state, CardState.State.BASE)
