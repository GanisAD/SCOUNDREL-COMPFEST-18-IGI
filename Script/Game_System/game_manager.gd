# game_manager.gd
extends Node

# --- KONFIGURASI BATAS PROGRES (CAPS) ---
const MIN_EXPLORED_ROOM_PER_FLOOR: int = 3
const MAX_ROOMS_PER_FLOOR: int = 4
const MAX_FLOOR: int = 13

# --- DATA PROGRES PEMAIN (RUN DATA) ---
var current_floor: int = 1
var max_floor: int = MAX_FLOOR
var explored_room: int = 0
var min_explored_room: int = MIN_EXPLORED_ROOM_PER_FLOOR
var player_hp: int = 100
var max_hp: int = 100
var player_gold: int = 0


# --- DATA PINTU YANG AKTIF ---

var active_doors_data: Array[RoomData] = []
var active_doors_states: Array[Door.State] = []

# --- DATA RUANGAN AKTIF ---

var current_room_data: RoomData = null


# --- FUNGSI PENGELOLAAN DATA ---

## Memeriksa apakah pemain sudah memenuhi batas minimal eksplorasi untuk memakai elevator
func can_use_elevator() -> bool:
	return explored_room >= MIN_EXPLORED_ROOM_PER_FLOOR

## Memeriksa apakah pemain sudah mencapai lantai teratas/maksimum
func is_at_max_floor() -> bool:
	return current_floor >= MAX_FLOOR

## Menambahkan progres ruangan yang telah dikunjungi dan memancarkan sinyal pembaruan
func record_room_explored() -> void:
	explored_room = mini(explored_room + 1, MAX_ROOMS_PER_FLOOR)
	Events.room_exploration_changed.emit(explored_room, MIN_EXPLORED_ROOM_PER_FLOOR)

## Berpindah ke lantai berikutnya jika belum mencapai batas maksimum.
## Mengembalikan true jika berhasil naik lantai, atau false jika sudah di lantai maksimum.
func advance_floor() -> bool:
	if is_at_max_floor():
		push_warning("GameManager: Sudah berada di lantai maksimum (%d)!" % MAX_FLOOR)
		return false
	
	current_floor += 1
	explored_room = 0
	active_doors_data.clear()
	active_doors_states.clear()
	
	Events.floor_changed.emit(current_floor, MAX_FLOOR)
	Events.room_exploration_changed.emit(explored_room, MIN_EXPLORED_ROOM_PER_FLOOR)
	return true

## Dipanggil saat memulai permainan/run baru dari awal
func start_new_run() -> void:
	current_floor = 1
	explored_room = 0
	active_doors_data.clear()
	active_doors_states.clear()
	player_hp = max_hp
	player_gold = 0
	current_room_data = null
	
	Events.floor_changed.emit(current_floor, MAX_FLOOR)
	Events.room_exploration_changed.emit(explored_room, MIN_EXPLORED_ROOM_PER_FLOOR)
	print("New Run Started!")

## Menyimpan data ruangan terpilih dan berpindah ke scene tujuan
func enter_room(room_data: RoomData, door_index: int = -1) -> void:
	current_room_data = room_data
	
	if door_index >= 0 and door_index < active_doors_states.size():
		active_doors_states[door_index] = Door.State.DISABLED
	
	if current_room_data == null:
		push_warning("GameManager: Enter room dipanggil tanpa RoomData!")
		return
		
	SceneManager.change_scene(SceneManager.SceneID.ROOM_EVENT)

## Dipanggil setelah pertempuran/event ruangan selesai untuk kembali ke pemilihan pintu
func return_to_dungeon_overworld() -> void:
	current_room_data = null
	SceneManager.change_scene(SceneManager.SceneID.EXPLORE)
