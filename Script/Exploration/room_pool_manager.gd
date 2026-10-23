# room_pool_manager.gd
## Pengelola data pool ruangan per run (Run-Level Room Pool Manager).
## Bertanggung jawab untuk menyusun deck 52 ruangan di awal run,
## memetakan ruangan per lantai dengan segmentasi level (Tier),
## serta menangani logika reshuffle saat pemain melakukan forfeit.
class_name RoomPoolManager
extends RefCounted

const DEFAULT_MAX_FLOOR: int = 13
const ROOMS_PER_FLOOR: int = 4
const TOTAL_ROOMS: int = 52

const DEFAULT_ROOM_PATHS: Dictionary = {
	RoomType.Type.CLUB: "res://Data/Room/club.tres",
	RoomType.Type.DIAMOND: "res://Data/Room/diamond.tres",
	RoomType.Type.HEART: "res://Data/Room/heart.tres",
	RoomType.Type.SPADE: "res://Data/Room/spade.tres",
}

## Mapping lantai ke daftar RoomData:
## Key: int (nomor lantai 1..max_floor)
## Value: Array[RoomData] (panjang ROOMS_PER_FLOOR)
var floor_rooms_pool: Dictionary = {}

## Pool kustom per tier / segmen (opsional, untuk level segmentation di masa depan):
var tier_1_pool: Array[RoomData] = [] # Lantai 1 - 4
var tier_2_pool: Array[RoomData] = [] # Lantai 5 - 8
var tier_3_pool: Array[RoomData] = [] # Lantai 9 - 12
var tier_4_pool: Array[RoomData] = [] # Lantai 13 (Puncak/Boss)

## Deck kustom 52 kartu (opsional, jika ingin menentukan deck spesifik):
var custom_master_deck: Array[RoomData] = []

## Cache resource default untuk menghindari disk I/O berulang
var _cached_default_rooms: Dictionary = {}

func _init() -> void:
	_load_default_room_resources()

## Memuat resource default ke dalam cache
func _load_default_room_resources() -> void:
	for room_type in DEFAULT_ROOM_PATHS.keys():
		var path = DEFAULT_ROOM_PATHS[room_type]
		if ResourceLoader.exists(path):
			var res = load(path)
			if res is RoomData:
				_cached_default_rooms[room_type] = res
			else:
				push_warning("RoomPoolManager: Resource di %s bukan bertipe RoomData!" % path)
		else:
			push_warning("RoomPoolManager: File template ruangan tidak ditemukan di %s" % path)

## Menghasilkan struktur pool ruangan untuk seluruh run (Lantai 1 sampai max_floor).
## Mendukung custom deck, segmented tier pools, dan fallback generator 52 kartu.
func generate_run_pool(max_floor: int = DEFAULT_MAX_FLOOR) -> void:
	floor_rooms_pool.clear()

	# Prioritas 1: Gunakan custom master deck jika disediakan
	if not custom_master_deck.is_empty():
		_generate_from_master_deck(custom_master_deck, max_floor)
		return

	# Prioritas 2: Gunakan segmented tier pools jika tersedia
	if _has_segmented_pools():
		_generate_from_segmented_tiers(max_floor)
		return

	# Prioritas 3 (Default): Buat 52-card balanced deck dari template default
	_generate_default_52_deck(max_floor)

## Mengambil daftar RoomData untuk lantai tertentu
func get_floor_rooms(floor_number: int) -> Array[RoomData]:
	if floor_rooms_pool.has(floor_number):
		var rooms: Array = floor_rooms_pool[floor_number]
		var typed_rooms: Array[RoomData] = []
		for r in rooms:
			if r is RoomData:
				typed_rooms.append(r)
		return typed_rooms

	# Fallback aman jika lantai belum terdaftar (resilience)
	push_warning("RoomPoolManager: Lantai %d belum ada di pool! Membuat fallback 4 ruangan." % floor_number)
	var fallback_rooms: Array[RoomData] = _create_fallback_floor_rooms()
	floor_rooms_pool[floor_number] = fallback_rooms
	return fallback_rooms

## Melakukan reshuffle ruangan yang di-forfeit ke lantai masa depan (future floor).
## Menimpa (overwrite) salah satu slot ruangan di lantai target.
## Mengembalikan dictionary status hasil reshuffle.
func reshuffle_room_to_future(room: RoomData, current_floor: int, max_floor: int = DEFAULT_MAX_FLOOR) -> Dictionary:
	var result := {
		"success": false,
		"reason": "",
		"target_floor": -1,
		"target_slot": -1,
		"overwritten_room": null
	}

	if room == null:
		result["reason"] = "room_is_null"
		return result

	# Jika sudah di lantai maksimum atau lebih, tidak ada lantai masa depan
	if current_floor >= max_floor:
		result["reason"] = "at_max_floor"
		return result

	# Pilih lantai target secara acak di masa depan (current_floor + 1 s/d max_floor)
	var target_floor: int = randi_range(current_floor + 1, max_floor)

	# Pastikan lantai target sudah memiliki daftar ruangan
	if not floor_rooms_pool.has(target_floor) or floor_rooms_pool[target_floor].is_empty():
		floor_rooms_pool[target_floor] = _create_fallback_floor_rooms()

	var target_rooms: Array = floor_rooms_pool[target_floor]
	var target_slot: int = randi_range(0, target_rooms.size() - 1)
	var overwritten: RoomData = target_rooms[target_slot]

	# Lakukan penimpaan data (overwrite)
	target_rooms[target_slot] = room
	floor_rooms_pool[target_floor] = target_rooms

	result["success"] = true
	result["reason"] = "reshuffled"
	result["target_floor"] = target_floor
	result["target_slot"] = target_slot
	result["overwritten_room"] = overwritten
	return result

# ==========================================
# INTERNAL GENERATION STRATEGIES
# ==========================================

func _generate_from_master_deck(deck: Array[RoomData], max_floor: int) -> void:
	var shuffled: Array[RoomData] = deck.duplicate()
	shuffled.shuffle()

	var index: int = 0
	for floor_num in range(1, max_floor + 1):
		var floor_rooms: Array[RoomData] = []
		for _s in range(ROOMS_PER_FLOOR):
			if index < shuffled.size():
				floor_rooms.append(shuffled[index])
				index += 1
			else:
				# Jika kartu habis, ambil acak dari deck
				floor_rooms.append(shuffled.pick_random())
		floor_rooms_pool[floor_num] = floor_rooms

func _has_segmented_pools() -> bool:
	return not (tier_1_pool.is_empty() and tier_2_pool.is_empty() and tier_3_pool.is_empty() and tier_4_pool.is_empty())

func _generate_from_segmented_tiers(max_floor: int) -> void:
	for floor_num in range(1, max_floor + 1):
		var source_tier: Array[RoomData] = _get_pool_for_floor_segment(floor_num)
		var floor_rooms: Array[RoomData] = []

		if source_tier.is_empty():
			floor_rooms = _create_fallback_floor_rooms()
		else:
			for _s in range(ROOMS_PER_FLOOR):
				floor_rooms.append(source_tier.pick_random())

		floor_rooms_pool[floor_num] = floor_rooms

func _get_pool_for_floor_segment(floor_num: int) -> Array[RoomData]:
	if floor_num <= 4 and not tier_1_pool.is_empty():
		return tier_1_pool
	elif floor_num <= 8 and not tier_2_pool.is_empty():
		return tier_2_pool
	elif floor_num <= 12 and not tier_3_pool.is_empty():
		return tier_3_pool
	elif floor_num >= 13 and not tier_4_pool.is_empty():
		return tier_4_pool
	return []

## Membuat deck seimbang 52 kartu (13 Club, 13 Diamond, 13 Heart, 13 Spade)
## lalu mengocok dan membagikannya ke 13 lantai (4 kartu per lantai).
func _generate_default_52_deck(max_floor: int) -> void:
	var deck: Array[RoomData] = []
	var available_types = _cached_default_rooms.values()

	if available_types.is_empty():
		push_error("RoomPoolManager: Tidak ada template RoomData yang tersedia untuk membuat deck!")
		return

	# 13 kartu untuk masing-masing suit = 52 kartu total
	for room_res in available_types:
		for _i in range(13):
			deck.append(room_res)

	deck.shuffle()

	var card_index: int = 0
	for floor_num in range(1, max_floor + 1):
		var floor_rooms: Array[RoomData] = []
		for _s in range(ROOMS_PER_FLOOR):
			if card_index < deck.size():
				floor_rooms.append(deck[card_index])
				card_index += 1
			else:
				floor_rooms.append(deck.pick_random())
		floor_rooms_pool[floor_num] = floor_rooms

func _create_fallback_floor_rooms() -> Array[RoomData]:
	var rooms: Array[RoomData] = []
	var available = _cached_default_rooms.values()
	if available.is_empty():
		return rooms

	for _i in range(ROOMS_PER_FLOOR):
		rooms.append(available.pick_random())
	return rooms
