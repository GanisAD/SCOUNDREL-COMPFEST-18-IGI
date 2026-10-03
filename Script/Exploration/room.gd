# room.gd
class_name Room
extends Control

## Referensi RoomData aktif yang sedang dimuat di ruangan ini
var current_room_data: RoomData
@onready var forfeit : Forfeit = $ForfeitButton
@onready var altar : Altar = $AltarSprite
@onready var promptPanel : PromptPanel = $PromptPanel

func _ready() -> void:
	# Ambil data ruangan yang disimpan di GameManager
	var active_room = GameManager.current_room_data

	if forfeit:
		forfeit.forfeit_used.connect(_on_forfeit_used)
	
	if promptPanel:
		promptPanel.yes_confirmation.connect(_on_prompt_yes_confirmed)

	if active_room:
		setup_room(active_room)
		
	

## Dipanggil saat pemain berpindah ke ruangan baru
func setup_room(room_data: RoomData) -> void:
	current_room_data = room_data
	
	altar.texture = current_room_data.room_altar

	# Memicu logika acak isi ruangan berdasarkan tipe ruangan
	if not altar:
		return
	
	match current_room_data.room_type:
		RoomType.Type.DIAMOND:
			altar.altar_used.connect(handle_weapon_room)
		RoomType.Type.HEART:
			altar.altar_used.connect(handle_potion_room)
		RoomType.Type.CLUB:
			altar.altar_used.connect(handle_monster_room)
		RoomType.Type.SPADE:
			altar.altar_used.connect(handle_tradeoff_room)

## Mengacak senjata dari possible_item_pool
func handle_weapon_room() -> void:
	var item_pool = current_room_data.possible_item_pool

	if item_pool.is_empty():
		return
	
	var chosen_weapon = item_pool.pick_random()

	if PlayerHandler.is_item_duplicate(chosen_weapon):
		print("Item duplikat: ", chosen_weapon.name)
		# Tampilkan pesan info tanpa payload (payload = null)
		promptPanel.show_prompt("Altar ini menawarkan " + chosen_weapon.name + ",tetapi kamu sudah memilikinya!", null)
		return

	var prompt = "Apakah anda ingin mengganti senjata menjadi : " + chosen_weapon.name 
	promptPanel.show_prompt(prompt, chosen_weapon)

## Mengacak potion dari possible_item_pool
func handle_potion_room() -> void:
	var item_pool = current_room_data.possible_item_pool
	if item_pool.is_empty():
		return
		
	var chosen_potion = item_pool.pick_random()

	# Jika potion juga dibatasi dari duplikasi
	if PlayerHandler.is_item_duplicate(chosen_potion):
		print("Potion duplikat: ", chosen_potion.name)
		promptPanel.show_prompt("Altar ini berisi " + chosen_potion.name + ",tetapi kamu sudah membawanya!", null)
		return

	# Langsung ambil atau tampilkan konfirmasi sesuai alur game
	_on_loot_button_pressed(chosen_potion)

## Mengacak musuh dari possible_monster_encounters
func handle_monster_room() -> void:
	var monster_pool = current_room_data.possible_monster_encounters
	if not monster_pool.is_empty():
		var chosen_encounter = monster_pool.pick_random()
		
		print("Player akan bertarung dengan : ", chosen_encounter)
		
		promptPanel.yes_confirmation.connect(_on_battle_confirmed)
		
		promptPanel.show_prompt("Apakah anda yakin akan bertarung melawan monster ini ?")

func handle_tradeoff_room() -> void:
	# Fitur sekunder (Spade)
	pass


func _on_forfeit_used() -> void:
	GameManager.return_to_dungeon_overworld()

func _on_battle_confirmed(_data = null) -> void:
	get_tree().change_scene_to_file("res://Scene/combat.tscn")

func _on_prompt_yes_confirmed(payload = null) -> void:
	# Jika payload kosong, berarti dialog hanya notifikasi penolakan duplikat (tidak ada aksi)
	if payload == null:
		return

	match current_room_data.room_type:
		RoomType.Type.CLUB:
			_on_battle_confirmed(payload)
		RoomType.Type.DIAMOND, RoomType.Type.HEART:
			if payload is ItemData:
				_on_loot_button_pressed(payload)

func _on_loot_button_pressed(item: ItemData) -> void:
	# Memanggil sinyal atau langsung ke PlayerHandler
	PlayerHandler.add_item_to_inventory(item)
	
	if altar:
		altar.set_altar_state(Altar.State.DISABLED)
