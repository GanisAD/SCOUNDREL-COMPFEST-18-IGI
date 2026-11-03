# game_manager.gd
extends Node

# --- KONFIGURASI BATAS PROGRES (CAPS) ---
const MIN_EXPLORED_ROOM_PER_FLOOR: int = 3
const MAX_ROOMS_PER_FLOOR: int = 4
const MAX_FLOOR: int = 13

# --- KONFIGURASI BALANCING FORFEIT ---
## Batas forfeit yang diizinkan per lantai (dapat disesuaikan untuk balancing)
const MAX_FORFEIT_PER_FLOOR: int = 1

# --- DATA PROGRES PEMAIN (RUN DATA) ---
var current_floor: int = 1
var max_floor: int = MAX_FLOOR
var explored_room: int = 0
var min_explored_room: int = MIN_EXPLORED_ROOM_PER_FLOOR
var player_hp: int = 100
var max_hp: int = 100
var player_gold: int = 0

## Pelacak jatah forfeit di lantai aktif saat ini
var forfeits_used_this_floor: int = 0

## Indeks pintu terakhir yang dimasuki pada lantai aktif
var last_entered_door_index: int = -1

# --- PENGELOLA POOL RUANGAN PER RUN ---
var room_pool_manager: RoomPoolManager = null

# --- DATA PINTU YANG AKTIF ---
var active_doors_data: Array[RoomData] = []
var active_doors_states: Array[Door.State] = []

# --- DATA RUANGAN AKTIF ---
var current_room_data: RoomData = null

func _ready() -> void:
	if room_pool_manager == null:
		room_pool_manager = RoomPoolManager.new()
	if active_doors_data.is_empty():
		start_new_run()

# --- FUNGSI PENGELOLAAN DATA & PROGRES ---

## Memeriksa apakah pemain sudah memenuhi batas minimal eksplorasi untuk memakai elevator
func can_use_elevator() -> bool:
	return explored_room >= MIN_EXPLORED_ROOM_PER_FLOOR

## Memeriksa apakah pemain sudah mencapai lantai teratas/maksimum
func is_at_max_floor() -> bool:
	return current_floor >= MAX_FLOOR

## Memeriksa apakah pemain masih diperbolehkan untuk melakukan forfeit di lantai ini
func can_forfeit() -> bool:
	return forfeits_used_this_floor < MAX_FORFEIT_PER_FLOOR

## Mengembalikan sisa jatah forfeit untuk lantai aktif
func get_remaining_forfeits() -> int:
	return maxi(0, MAX_FORFEIT_PER_FLOOR - forfeits_used_this_floor)

## Menambahkan progres ruangan yang telah dikunjungi dan memancarkan sinyal pembaruan
func record_room_explored() -> void:
	explored_room = mini(explored_room + 1, MAX_ROOMS_PER_FLOOR)
	Events.room_exploration_changed.emit(explored_room, MIN_EXPLORED_ROOM_PER_FLOOR)

## Memuat data pintu untuk lantai tertentu dari RoomPoolManager
func load_floor_doors(floor_number: int) -> void:
	active_doors_data.clear()
	active_doors_states.clear()
	
	if room_pool_manager == null:
		room_pool_manager = RoomPoolManager.new()
		room_pool_manager.generate_run_pool(max_floor)
		
	var floor_rooms = room_pool_manager.get_floor_rooms(floor_number)
	for room in floor_rooms:
		active_doors_data.append(room)
		active_doors_states.append(Door.State.AVAILABLE)

## Berpindah ke lantai berikutnya jika belum mencapai batas maksimum.
## Mengembalikan true jika berhasil naik lantai, atau false jika sudah di lantai maksimum.
func advance_floor() -> bool:
	if is_at_max_floor():
		push_warning("GameManager: Sudah berada di lantai maksimum (%d)!" % MAX_FLOOR)
		return false
	
	current_floor += 1
	explored_room = 0
	forfeits_used_this_floor = 0
	last_entered_door_index = -1
	
	load_floor_doors(current_floor)
	
	Events.floor_changed.emit(current_floor, MAX_FLOOR)
	Events.room_exploration_changed.emit(explored_room, MIN_EXPLORED_ROOM_PER_FLOOR)
	Events.forfeit_state_changed.emit(can_forfeit(), get_remaining_forfeits())
	return true

## Dipanggil saat memulai permainan/run baru dari awal
func start_new_run() -> void:
	current_floor = 1
	explored_room = 0
	forfeits_used_this_floor = 0
	last_entered_door_index = -1
	player_hp = max_hp
	player_gold = 0
	current_room_data = null
	
	if room_pool_manager == null:
		room_pool_manager = RoomPoolManager.new()
	room_pool_manager.generate_run_pool(max_floor)
	
	load_floor_doors(current_floor)
	
	Events.floor_changed.emit(current_floor, MAX_FLOOR)
	Events.room_exploration_changed.emit(explored_room, MIN_EXPLORED_ROOM_PER_FLOOR)
	Events.forfeit_state_changed.emit(can_forfeit(), get_remaining_forfeits())
	print("New Run Started with Room Pooling!")

## Menyimpan data ruangan terpilih dan berpindah ke scene tujuan
func enter_room(room_data: RoomData, door_index: int = -1) -> void:
	current_room_data = room_data
	last_entered_door_index = door_index
	
	if door_index >= 0 and door_index < active_doors_states.size():
		active_doors_states[door_index] = Door.State.DISABLED
	
	if current_room_data == null:
		push_warning("GameManager: Enter room dipanggil tanpa RoomData!")
		return
		
	SceneManager.change_scene(SceneManager.SceneID.ROOM_EVENT)

## Dipanggil saat pemain memutuskan forfeit di suatu ruangan.
## Mengembalikan ruangan ke pool masa depan (menimpa slot lain) jika belum di lantai maksimum,
## menonaktifkan pintu asal, dan kembali ke overworld dungeon.
func forfeit_current_room() -> bool:
	if not can_forfeit():
		push_warning("GameManager: Forfeit ditolak! Jatah forfeit lantai %d sudah habis." % current_floor)
		return false
	
	forfeits_used_this_floor += 1
	Events.forfeit_state_changed.emit(can_forfeit(), get_remaining_forfeits())
	
	# Pastikan pintu asal dinonaktifkan
	if last_entered_door_index >= 0 and last_entered_door_index < active_doors_states.size():
		active_doors_states[last_entered_door_index] = Door.State.DISABLED
	
	var forfeited_room = current_room_data
	if forfeited_room and room_pool_manager:
		if current_floor < max_floor:
			var reshuffle_result = room_pool_manager.reshuffle_room_to_future(forfeited_room, current_floor, max_floor)
			if reshuffle_result.get("success", false):
				var target_floor = reshuffle_result["target_floor"]
				var target_slot = reshuffle_result["target_slot"]
				var overwritten = reshuffle_result["overwritten_room"]
				print("GameManager: Room '%s' di-reshuffle dari Lt.%d ke Lt.%d slot %d (menimpa '%s')" % [
					forfeited_room.room_name,
					current_floor,
					target_floor,
					target_slot,
					overwritten.room_name if overwritten else "Empty"
				])
				Events.room_reshuffled.emit(
					current_floor,
					target_floor,
					target_slot,
					forfeited_room,
					overwritten
				)
		else:
			print("GameManager: Forfeit di lantai maksimum (%d). Ruangan langsung dihapus." % current_floor)
	
	return_to_dungeon_overworld()
	return true

func enter_battle_scene(Enemy:EnemyStats) -> void:
	Events.combat_start.emit(Enemy)
	SceneManager.change_scene(SceneManager.SceneID.COMBAT)
	print("Player melawan : ", Enemy.enemy_name)

## Dipanggil setelah pertempuran/event ruangan selesai untuk kembali ke pemilihan pintu
func return_to_dungeon_overworld() -> void:
	current_room_data = null
	SceneManager.change_scene(SceneManager.SceneID.EXPLORE)
