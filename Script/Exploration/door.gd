# door.gd
class_name Door
extends Control

signal door_selected(room_data: RoomData)

enum State { LOCKED, AVAILABLE, DISABLED }

@export var possible_rooms: Array[RoomData] = []
@onready var icon_frame : TextureRect = $IconFrame

var current_state: State = State.AVAILABLE
var assigned_room_data: RoomData

func _ready() -> void:
	# Hubungkan sinyal mouse bawaan Control
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	
	# generate_random_room()

func set_room_data(data: RoomData) -> void:
	assigned_room_data = data
	update_visual()

func generate_random_room() -> RoomData:
	if possible_rooms.is_empty():
		return
	
	assigned_room_data = possible_rooms.pick_random()
	update_visual()
	return assigned_room_data;

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


func update_visual() -> void:
	if icon_frame and assigned_room_data:
		icon_frame.texture = assigned_room_data.room_icon

func _on_gui_input(event: InputEvent) -> void:
	if current_state != State.AVAILABLE:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		set_door_state(State.DISABLED)
		door_selected.emit(assigned_room_data)
