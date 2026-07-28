# game_manager.gd
extends Node

# --- DATA PROGRES PEMAIN (RUN DATA) ---
var current_floor: int = 1
var player_hp: int = 100
var max_hp: int = 100
var player_gold: int = 0

# --- DATA RUANGAN AKTIF ---
var current_room_data: RoomData = null


# --- FUNGSI PENGELOLAAN DATA ---

## Dipanggil saat memulai permainan/run baru dari awal
func start_new_run() -> void:
	current_floor = 1
	player_hp = max_hp
	player_gold = 0
	current_room_data = null
	print("New Run Started!")

## Menyimpan data ruangan terpilih dan berpindah ke scene tujuan
func enter_room(room_data: RoomData) -> void:
	current_room_data = room_data
	
	if current_room_data == null:
		push_warning("GameManager: Enter room dipanggil tanpa RoomData!")
		return
		
	# Tentukan pindah scene berdasarkan tipe ruangan
	#match current_room_data.room_type:
		#RoomType.Type.CLUB:
			## Berpindah ke scene pertarungan utama
			#get_tree().change_scene_to_file("res://Scene/combat.tscn")
		#_:
	# Tipe ruangan lain (Diamond, Heart, Spade) ke scene event/loot
	get_tree().change_scene_to_file("res://Scene/Components/room_event.tscn")

## Dipanggil setelah pertempuran/event ruangan selesai untuk kembali ke pemilihan pintu
func return_to_dungeon_overworld() -> void:
	current_room_data = null
	get_tree().change_scene_to_file("res://scenes/dungeon_overworld.tscn")
