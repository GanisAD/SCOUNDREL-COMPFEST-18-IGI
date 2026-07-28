# elevator.gd
class_name Elevator
extends Button

signal elevator_used

func _ready() -> void:
	# Menghubungkan sinyal klik bawaan Button ke pemancar sinyal elevator_used
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("Elevator: Tombol dipencet!")
	elevator_used.emit()
