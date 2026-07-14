extends Node

# ==========================================
# EVENT KARTU & INTERAKSI UI
# ==========================================
## Dipanggil saat kartu dengan target spesifik (SINGLE_ENEMY) ditarik melewati batas
signal card_aim_started(card_ui: CardUI)

## Dipanggil saat pemain batal membidik atau melepaskan kartu
signal card_aim_ended(card_ui: CardUI)

## Dipanggil saat kartu valid dilepaskan di area drop
signal card_played(card: Card)

# ==========================================
# EVENT TOOLTIP
# ==========================================
## Dipanggil saat mouse *hover* di atas kartu untuk memunculkan deskripsi
signal card_tooltip_requested(card: Card)
signal tooltip_hide_requested

# ==========================================
# EVENT STATUS PEMAIN & MUSUH (Untuk Nanti)
# ==========================================
signal player_hand_drawn
signal enemy_turn_started
signal player_mana_changed(new_mana: int)

## Dipanggil saat pemain mulai menyeret kartu (transisi ke status Dragging)
signal card_drag_started(card_ui: CardUI) 

## Dipanggil saat pemain melepaskan atau membatalkan seretan kartu
signal card_drag_ended(card_ui: CardUI)
