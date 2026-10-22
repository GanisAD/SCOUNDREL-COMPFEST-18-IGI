# elevator.gd
class_name Elevator
extends Button

signal elevator_used

func _ready() -> void:
	# Menghubungkan sinyal klik bawaan Button ke pemancar sinyal elevator_used
	pressed.connect(_on_pressed)
	
func _process(_delta: float) -> void:
	if GameManager.explored_room < GameManager.min_explored_room:
		modulate = Color(0.3, 0.3, 0.3)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		modulate = Color.WHITE
		mouse_filter = Control.MOUSE_FILTER_STOP


func _on_pressed() -> void:
	print("Elevator: Tombol dipencet!")
	elevator_used.emit()
