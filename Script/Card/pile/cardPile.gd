class_name CardPile
extends Resource

# Array yang secara ketat hanya menerima tipe data 'Card' (Custom Resource lain)
@export var cards: Array[Card] = []

# Sinyal opsional jika UI perlu tahu kapan tumpukan berubah jumlahnya
signal pile_size_changed(new_size: int)

# Mengecek apakah tumpukan kosong
func is_empty() -> bool:
	return cards.is_empty()

# Menarik kartu teratas (elemen pertama di array)
func draw_card() -> Card:
	if is_empty():
		return null
	
	var drawn_card = cards.pop_front()
	pile_size_changed.emit(cards.size())
	return drawn_card

# Menambahkan kartu ke tumpukan (untuk discard pile atau saat mengocok ulang)
func add_card(card: Card) -> void:
	cards.append(card)
	pile_size_changed.emit(cards.size())

# Mengocok tumpukan kartu (sangat penting untuk draw pile)
func shuffle() -> void:
	cards.shuffle()

# Mengosongkan seluruh isi tumpukan
func clear() -> void:
	cards.clear()
	pile_size_changed.emit(cards.size())
