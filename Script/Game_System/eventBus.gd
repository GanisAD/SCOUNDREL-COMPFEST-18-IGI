extends Node

# ==========================================
# EVENT KARTU & INTERAKSI UI
# ==========================================
## Dipanggil saat kartu dengan target spesifik (SINGLE_ENEMY) ditarik melewati batas
@warning_ignore("unused_signal")
signal card_aim_started(card_ui: CardUI)

## Dipanggil saat pemain batal membidik atau melepaskan kartu
@warning_ignore("unused_signal")
signal card_aim_ended(card_ui: CardUI)

## Dipanggil saat kartu valid dilepaskan di area drop
@warning_ignore("unused_signal")
signal card_played(card: Card)

## Dipanggil saat pemain mulai menyeret kartu (transisi ke status Dragging)
@warning_ignore("unused_signal")
signal card_drag_started(card_ui: CardUI) 

## Dipanggil saat pemain melepaskan atau membatalkan seretan kartu
@warning_ignore("unused_signal")
signal card_drag_ended(card_ui: CardUI)


# ==========================================
# EVENT TOOLTIP
# ==========================================
## Dipanggil saat mouse *hover* di atas kartu untuk memunculkan deskripsi
@warning_ignore("unused_signal")
signal card_tooltip_requested(card: Card)
@warning_ignore("unused_signal")
signal tooltip_hide_requested

# ==========================================
# EVENT STATUS PEMAIN
# ==========================================
@warning_ignore("unused_signal")
signal player_hand_drawn
@warning_ignore("unused_signal")
signal player_hand_discarded

@warning_ignore("unused_signal")
signal player_turn_started
@warning_ignore("unused_signal")
signal player_turn_ended

@warning_ignore("unused_signal")
signal player_mana_changed(new_mana: int)

@warning_ignore("unused_signal")
signal player_died

# ==========================================
#  EVENT STATUS MUSUH 
# ==========================================

@warning_ignore("unused_signal")
signal enemy_turn_started
@warning_ignore("unused_signal")
signal enemy_turn_ended
