extends Node
class_name PlayerHandler 

# Jeda waktu (dalam detik) antar penarikan kartu agar kartu tidak muncul sekaligus 
const HAND_DRAW_INTERVAL := 0.25 

# Dependensi ke Node Hand (HBoxContainer) untuk merender kartu secara visual 
@export var hand: Node 

# Variabel untuk menampung data statistik dan tumpukan kartu 
var character_stats: CharacterStats 
var draw_pile: CardPile 
var discard_pile: CardPile 

# Fungsi utama untuk memulai simulasi pertempuran 
func start_battle(stats: CharacterStats) -> void:
	character_stats = stats 
	
	# Membuat deep copy dari dek awal agar perubahan di dalam battle tidak merusak dek asli 
	draw_pile = character_stats.deck.duplicate(true) 
	draw_pile.shuffle() # Mengocok tumpukan kartu di awal permainan 
	
	# Menyiapkan tumpukan buangan yang masih kosong 
	discard_pile = CardPile.new() 
	
	# Panggil fungsi untuk memulai giliran pertama 
	start_turn() 

# Fungsi untuk memulai giliran baru pemain 
func start_turn() -> void:
	# Mereset status pertahanan (Block) dan Mana pemain 
	character_stats.block = 0 
	character_stats.reset_mana() # Asumsi fungsi kustom untuk mereset Mana kembali penuh 
	
	# Menarik kartu secara berkala sesuai dengan jumlah kartu per turn milik karakter 
	draw_cards(character_stats.cards_per_turn) 

# Logika inti untuk menarik satu kartu 
func draw_card() -> void:
	# Cek dan lakukan kocok ulang jika tumpukan kartu tarik ternyata kosong 
	reshuffle_deck_from_discard() 
	
	# Mengambil satu kartu dari posisi paling atas tumpukan draw_pile 
	var card = draw_pile.draw_card() # Asumsi fungsi draw_card() ada di kelas CardPile Anda 
	if card:
		hand.add_card_to_hand(card) # Memanggil fungsi publik milik hand.gd untuk melahirkan visual kartu 
		
	# Pengecekan ulang setelah penarikan kartu selesai dijalankan 
	reshuffle_deck_from_discard() 

# Fungsi manajemen jeda (Tween) untuk menarik beberapa kartu sekaligus 
func draw_cards(amount: int) -> void:
	var tween := create_tween() 
	
	# Melakukan perulangan penarikan kartu berdasarkan jumlah yang diminta 
	for i in range(amount):
		tween.tween_callback(draw_card) # Memanggil fungsi draw_card secara bergantian 
		tween.tween_interval(HAND_DRAW_INTERVAL) # Memberikan jeda waktu sesuai konstanta kita 
		
	# Setelah semua kartu selesai ditarik ke tangan, pancarkan sinyal global melalui Event Bus 
	tween.finished.connect(
		func():
			Events.player_hand_drawn.emit() 
	)

# Logika pengocokan ulang kartu buangan kembali ke dek tarik jika habis 
func reshuffle_deck_from_discard() -> void:
	# Jika tumpukan kartu tarik belum habis, lewati proses ini segera 
	if not draw_pile.is_empty():
		return 
		
	# Pindahkan seluruh sisa kartu dari tumpukan buangan kembali ke tumpukan tarik 
	while not discard_pile.is_empty():
		var card = discard_pile.draw_card() 
		draw_pile.add_card(card) 
		
	# Kocok ulang tumpukan tarik yang baru agar urutannya acak kembali 
	draw_pile.shuffle()
