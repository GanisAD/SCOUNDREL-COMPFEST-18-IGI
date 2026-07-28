# door.gd
class_name Door
extends Control # Atau Control / Button sesuai setup Anda

signal door_entered(selected_room_data: RoomData)

## Referensi ke node visual tempat menampilkan ikon (Sprite2D atau TextureRect)
@export var icon_display: Sprite2D # Ganti ke TextureRect jika menggunakan UI Control

## Pool jenis ruangan yang BISA dimunculkan oleh pintu ini
@export var possible_rooms: Array[RoomData] = []

## Menampung hasil acak ruangan untuk pintu ini
var assigned_room_data: RoomData

func _ready() -> void:
	generate_random_room()

## Mengacak jenis ruangan dan memperbarui tampilan ikon
func generate_random_room() -> void:
	if possible_rooms.is_empty():
		push_warning("Door: Pool possible_rooms masih kosong!")
		return
	
	# 1. Ambil satu RoomData secara acak dari pool
	assigned_room_data = possible_rooms.pick_random()
	
	# 2. Perbarui visual ikon di pintu
	update_door_visual()

## Mengatur tekstur ikon berdasarkan RoomData yang didapat
func update_door_visual() -> void:
	if assigned_room_data and icon_display:
		if assigned_room_data.room_icon:
			icon_display.texture = assigned_room_data.room_icon
		else:
			push_warning("RoomData '" + assigned_room_data.room_name + "' belum memiliki room_icon!")

## Dipanggil saat pemain berinteraksi dengan pintu ini
func enter_door() -> void:
	if assigned_room_data:
		door_entered.emit(assigned_room_data)
