class_name CardStateMachine
extends Node

# 1. Konfigurasi Awal
@export var initial_state: CardState

var current_state: CardState
var states := {} # Dictionary untuk menyimpan referensi semua state anak

# 2. Fungsi Inisialisasi (Dipanggil oleh CardUI nantinya)
func init(card: CardUI) -> void:
	# Melakukan iterasi (loop) ke semua child node dari mesin ini
	for child in get_children():
		if child is CardState:
			# Menyimpan state ke dalam dictionary menggunakan Enum sebagai Key
			states[child.state] = child
			# Menghubungkan sinyal permintaan transisi dari child ke fungsi lokal
			child.transition_requested.connect(_on_transition_requested)
			# Menyuntikkan referensi CardUI ke dalam state
			child.card_ui = card
			
	# Mengatur state awal
	if initial_state:
		initial_state.enter()
		current_state = initial_state

# 3. Routing Input (Meneruskan event ke state yang sedang aktif)
func on_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_input(event)

func on_gui_input(event: InputEvent) -> void:
	if current_state:
		current_state.on_gui_input(event)

func on_mouse_entered() -> void:
	if current_state:
		current_state.on_mouse_entered()

func on_mouse_exited() -> void:
	if current_state:
		current_state.on_mouse_exited()

# 4. Logika Transisi
func _on_transition_requested(from: CardState.State, to: CardState.State) -> void:
	# Keamanan: Tolak transisi jika state yang meminta bukan state yang sedang aktif
	if from != current_state.state:
		return
		
	# Ambil referensi state tujuan dari dictionary
	var new_state: CardState = states[to]
	if not new_state:
		return
		
	# Eksekusi perpindahan
	if current_state:
		current_state.exit()
		
	new_state.enter()
	current_state = new_state
