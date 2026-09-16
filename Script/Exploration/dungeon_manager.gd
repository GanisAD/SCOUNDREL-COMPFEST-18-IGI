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
	
	update_floor_ui()

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
	for door in doors:
		if door:
			door.generate_random_room()
