# room.gd
class_name Room
extends Node

## Referensi RoomData aktif yang sedang dimuat di ruangan ini
var current_room_data: RoomData

## Dipanggil saat pemain berpindah ke ruangan baru
func setup_room(room_data: RoomData) -> void:
	current_room_data = room_data
	print("Memasuki Ruangan: ", current_room_data.room_name)
	
	# Memicu logika acak isi ruangan berdasarkan tipe ruangan
	match current_room_data.room_type:
		RoomType.Type.DIAMOND:
			handle_weapon_room()
		RoomType.Type.HEART:
			handle_potion_room()
		RoomType.Type.CLUB:
			handle_monster_room()
		RoomType.Type.SPADE:
			handle_tradeoff_room()

## Mengacak senjata dari possible_item_pool
func handle_weapon_room() -> void:
	var item_pool = current_room_data.possible_item_pool
	if not item_pool.is_empty():
		var chosen_weapon = item_pool.pick_random()
		print("Loot Senjata Didapatkan: ", chosen_weapon)
		# TODO: Tampilkan UI hadiah senjata atau tambahkan ke inventaris pemain

## Mengacak potion dari possible_item_pool
func handle_potion_room() -> void:
	var item_pool = current_room_data.possible_item_pool
	if not item_pool.is_empty():
		var chosen_potion = item_pool.pick_random()
		print("Loot Potion Didapatkan: ", chosen_potion)
		# TODO: Tampilkan UI pilihan potion / langsung sembuhkan HP

## Mengacak musuh dari possible_monster_encounters
func handle_monster_room() -> void:
	var monster_pool = current_room_data.possible_monster_encounters
	if not monster_pool.is_empty():
		var chosen_encounter = monster_pool.pick_random()
		print("Pertarungan Dimulai dengan: ", chosen_encounter)
		# TODO: Panggil / Transisi ke BattleScene dengan membawa data encounter ini

func handle_tradeoff_room() -> void:
	# Fitur sekunder (Spade)
	pass
