# elevator.gd
class_name Elevator
extends Button

signal elevator_used

func _ready() -> void:
	# Menghubungkan sinyal klik bawaan Button ke pemancar sinyal elevator_used
	pressed.connect(_on_pressed)
	
	# Dengarkan perubahan progres eksplorasi secara reaktif
	Events.room_exploration_changed.connect(_on_room_exploration_changed)
	
	# Inisialisasi tampilan awal sesuai data di GameManager
	update_state(GameManager.explored_room, GameManager.MIN_EXPLORED_ROOM_PER_FLOOR)

func _on_room_exploration_changed(current: int, required_min: int) -> void:
	update_state(current, required_min)

func update_state(current: int, required_min: int) -> void:
	var is_unlocked: bool = current >= required_min
	disabled = not is_unlocked
	
	if is_unlocked:
		modulate = Color.WHITE
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		modulate = Color(0.4, 0.4, 0.4)
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_pressed() -> void:
	if not disabled:
		print("Elevator: Tombol dipencet!")
		elevator_used.emit()

