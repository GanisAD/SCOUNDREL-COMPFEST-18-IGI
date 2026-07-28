# elevator.gd
class_name Elevator
extends Button # Atau Area2D jika berupa objek fisik di dunia 2D

signal elevator_used

func _on_pressed() -> void:
	# Memancarkan sinyal saat pemain menekan tombol lift
	elevator_used.emit()
