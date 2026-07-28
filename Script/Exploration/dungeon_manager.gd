# dungeon_manager.gd
class_name DungeonManager
extends Node

@export var elevator: Elevator
@export var doors: Array[Door] = []

var current_floor: int = 1

func _ready() -> void:
	# Hubungkan sinyal dari elevator ke fungsi reroll
	if elevator:
		elevator.elevator_used.connect(_on_elevator_used)

func _on_elevator_used() -> void:
	current_floor += 1
	print("Pindah ke Floor: ", current_floor)
	
	# Panggil fungsi reroll di semua pintu
	reroll_all_doors()

func reroll_all_doors() -> void:
	for door in doors:
		if door:
			door.generate_random_room()
