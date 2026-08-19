# elevator.gd
class_name Forfeit
extends Button

signal forfeit_used

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("Forfeit: Tombol dipencet!")
	forfeit_used.emit()
