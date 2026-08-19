# door.gd
class_name Door
extends Control

signal door_selected(room_data: RoomData)

enum State { LOCKED, AVAILABLE, DISABLED }

@export var icon_display: TextureRect
@export var possible_rooms: Array[RoomData] = []

var current_state: State = State.AVAILABLE
var assigned_room_data: RoomData

func _ready() -> void:
	# Hubungkan sinyal mouse bawaan Control
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	
	generate_random_room()

func generate_random_room() -> void:
	if possible_rooms.is_empty():
		return
	assigned_room_data = possible_rooms.pick_random()
	if icon_display and assigned_room_data:
		icon_display.texture = assigned_room_data.room_icon

func set_door_state(new_state: State) -> void:
	current_state = new_state
	match current_state:
		State.LOCKED:
			modulate = Color(0.4, 0.4, 0.4) # Visual redup/terkunci
		State.AVAILABLE:
			modulate = Color.WHITE
		State.DISABLED:
			modulate = Color(0.2, 0.2, 0.2)

func _on_mouse_entered() -> void:
	if current_state == State.AVAILABLE:
		# Animasi Hover Sederhana (Tweening scale)
		create_tween().tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)

func _on_mouse_exited() -> void:
	if current_state == State.AVAILABLE:
		create_tween().tween_property(self, "scale", Vector2.ONE, 0.1)

func _on_gui_input(event: InputEvent) -> void:
	if current_state != State.AVAILABLE:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		set_door_state(State.DISABLED)
		# Panggil GameManager untuk langsung pindah scene sesuai RoomData pintu ini
		GameManager.enter_room(assigned_room_data)
