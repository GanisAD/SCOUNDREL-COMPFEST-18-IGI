class_name PromptPanel
extends Panel

# Membuat sinyal kustom untuk didengarkan oleh skrip lain
signal yes_confirmation(ItemData)
signal no_confirmation

@onready var promptLabel = $PromptLabel
var current_data = null

func _ready():
	# Pastikan panel tersembunyi saat game baru dimulai
	visible = false

# Fungsi ini yang akan dipanggil untuk memunculkan panel
func show_prompt(messages: String = "Apakah Anda yakin?", payload = null):
	promptLabel.text = messages
	current_data = payload
	show()

# Fungsi internal saat tombol Ya ditekan
func _on_btn_yes_pressed():
	yes_confirmation.emit(current_data) # Pancarkan sinyal Ya
	_close_panel()
# Fungsi internal saat tombol Tidak ditekan
func _on_btn_no_pressed():
	no_confirmation.emit() # Pancarkan sinyal Tidak
	_close_panel()

func _close_panel() -> void:
	current_data = null # Selalu bersihkan data saat panel ditutup
	hide()
