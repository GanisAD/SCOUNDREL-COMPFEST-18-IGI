## Tombol menyerah / forfeit dalam eksplorasi ruangan.
## Memancarkan sinyal forfeit_used saat ditekan oleh pemain.
class_name Forfeit
extends Button

## Dipancarkan saat tombol forfeit diklik.
signal forfeit_used

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	Events.ui_button_clicked.emit()
	print("Forfeit: Tombol dipencet!")
	forfeit_used.emit()
