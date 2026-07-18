extends Label
class_name CardPileUI

@export var format_text: String = "Discard Pile: %d"

# Variabel ini akan menampung referensi objek CardPile asli dari PlayerHandler
var target_pile: CardPile : set = set_target_pile

func set_target_pile(new_pile: CardPile) -> void:
	target_pile = new_pile
	
	# Hubungkan sinyal dari data ke fungsi update teks di bawah
	if not target_pile.pile_size_changed.is_connected(_on_pile_size_changed):
		target_pile.pile_size_changed.connect(_on_pile_size_changed)
	
	# Set tulisan angka pertama kali saat game dimulai
	_on_pile_size_changed(target_pile.cards.size())

# Fungsi ini otomatis berjalan setiap kali data kartu bertambah/berkurang
func _on_pile_size_changed(current_size: int) -> void:
	text = format_text % current_size
