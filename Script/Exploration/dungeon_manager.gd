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

	for door in doors:
		if door:
			door.door_selected.connect(_on_door_selected)

	update_floor_ui()
	setup_doors_state()

func setup_doors_state() -> void:
	# Cek apakah GameManager sudah memiliki data pintu dari sebelum forfeit/battle
	if GameManager.active_doors_data.size() == doors.size():
		# Muat kembali state pintu sebelumnya (TIDAK DIACAK ULANG)
		for i in range(doors.size()):
			if doors[i]:
				doors[i].set_room_data(GameManager.active_doors_data[i])
	else:
		# Jika belum ada data (awal lantai/game baru), acak semua pintu
		reroll_all_doors()


func _on_door_selected(selected_room: RoomData) -> void:
	GameManager.enter_room(selected_room)

func _on_elevator_used() -> void:
	
	GameManager.current_floor += 1
	update_floor_ui()
	reroll_all_doors()

func update_floor_ui() -> void:
	if floor_label:
		floor_label.text = "Current Floor : %d" % GameManager.current_floor
	else:
		push_error("DungeonManager: floor_label TIDAK DITEMUKAN / NULL!")

func reroll_all_doors() -> void:
	GameManager.active_doors_data.clear()
	for door in doors:
		if door:
			var new_room = door.generate_random_room()
			GameManager.active_doors_data.append(new_room)