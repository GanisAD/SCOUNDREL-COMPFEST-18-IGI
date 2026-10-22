# dungeon_manager.gd
class_name DungeonManager
extends Node

@export var elevator: Elevator
@export var doors: Array[Door] = []

@onready var floor_label : Label = $floorLabel

func _ready() -> void:
	# Hubungkan sinyal dari elevator ke fungsi reroll
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
	# Cek apakah GameManager sudah memiliki data pintu dari sebelum forfeit/battle
	if GameManager.active_doors_data.size() == doors.size():
		# Muat kembali state pintu sebelumnya (TIDAK DIACAK ULANG)
		for i in range(doors.size()):
			if doors[i]:
				doors[i].set_room_data(GameManager.active_doors_data[i])
				var saved_state = GameManager.active_doors_states[i]
				doors[i].set_door_state(saved_state)
	else:
		# Jika belum ada data (awal lantai/game baru), acak semua pintu
		reroll_all_doors()


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
		reroll_all_doors()

func update_floor_ui(floor_number: int = GameManager.current_floor) -> void:
	if floor_label:
		floor_label.text = "Current Floor : %d" % floor_number
	else:
		push_error("DungeonManager: floor_label TIDAK DITEMUKAN / NULL!")

func reroll_all_doors() -> void:
	GameManager.active_doors_data.clear()
	GameManager.active_doors_states.clear()
	
	for door in doors:
		if door:
			var new_room = door.generate_random_room()
			door.set_door_state(Door.State.AVAILABLE)
			
			GameManager.active_doors_data.append(new_room)
			GameManager.active_doors_states.append(Door.State.AVAILABLE)
