## Panel modal dialog konfirmasi (Yes / No).
## Menampilkan pesan konfirmasi interaktif dengan payload data opsional (misal: ItemData).
class_name PromptPanel
extends Panel

## Dipancarkan saat pemain mengonfirmasi pilihan (menekan tombol Ya).
signal yes_confirmation(item_data: ItemData)
## Dipancarkan saat pemain membatalkan pilihan (menekan tombol Tidak).
signal no_confirmation

@onready var promptLabel = $PromptLabel
var current_data = null

func _ready() -> void:
	# Pastikan panel tersembunyi saat game baru dimulai
	visible = false

## Memunculkan panel dialog dengan pesan khusus dan payload data.
## [param messages]: Teks pesan konfirmasi yang ditampilkan ke pemain.
## [param payload]: Data referensi (misal ItemData) yang akan dikirim kembali saat tombol Ya ditekan.
func show_prompt(messages: String = "Apakah Anda yakin?", payload = null) -> void:
	promptLabel.text = messages
	current_data = payload
	show()

func _on_btn_yes_pressed() -> void:
	Events.ui_button_clicked.emit()
	yes_confirmation.emit(current_data)
	_close_panel()

func _on_btn_no_pressed() -> void:
	Events.ui_button_clicked.emit()
	no_confirmation.emit()
	_close_panel()

func _close_panel() -> void:
	current_data = null
	hide()
