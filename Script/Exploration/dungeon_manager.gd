# dungeon_manager.gd
class_name DungeonManager
extends Node

@export var elevator: Elevator
@export var doors: Array[Door] = []

@onready var floor_label : Label = $floorLabel

func _ready() -> void:
	# Hubungkan sinyal dari elevator ke fungsi reroll/advance floor
	if elevator:
		elevator.elevator_used.connect(_on_elevator_used)

	for i in range(doors.size()):
		var door = doors[i]
		if door:
			door.door_index = i
			door.door_selected.connect(_on_door_selected)
	
	Events.floor_changed.connect(_on_floor_changed)
	update_floor_ui()
	setup_doors_state()

func _on_floor_changed(new_floor: int, _max_floor: int) -> void:
	update_floor_ui(new_floor)

func setup_doors_state() -> void:
	# Jika data pintu belum siap untuk lantai ini, muat dari RoomPoolManager di GameManager
	if GameManager.active_doors_data.size() != doors.size():
		GameManager.load_floor_doors(GameManager.current_floor)

	# Terapkan data dan state pintu dari GameManager
	for i in range(doors.size()):
		if doors[i]:
			if i < GameManager.active_doors_data.size():
				doors[i].set_room_data(GameManager.active_doors_data[i])
			if i < GameManager.active_doors_states.size():
				doors[i].set_door_state(GameManager.active_doors_states[i])

func _on_door_selected(selected_room: RoomData, index: int) -> void:
	for door in doors:
		if door:
			door.set_door_state(Door.State.DISABLED)
	
	GameManager.record_room_explored()
	GameManager.enter_room(selected_room, index)

func _on_elevator_used() -> void:
	if GameManager.is_at_max_floor():
		print("DungeonManager: Mencapai akhir labirin (lantai maksimum)!")
		Events.dungeon_completed.emit()
		return
	
	if GameManager.advance_floor():
		setup_doors_state()

func update_floor_ui(floor_number: int = GameManager.current_floor) -> void:
	if floor_label:
		floor_label.text = "Current Floor : %d" % floor_number
	else:
		push_error("DungeonManager: floor_label TIDAK DITEMUKAN / NULL!")
