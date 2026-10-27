## EventBus (Autoload: Events)
##
## Pusat stasiun komunikasi global (Publish-Subscribe Pattern) untuk proyek ALTAR-52.
## Menghubungkan berbagai sistem yang terisolasi (UI, Combat, Card FSM, dan Audio)
## tanpa membuat dependensi langsung antar kelas (loose coupling).
class_name EventBus
extends Node

# ==========================================
# EVENT KARTU & INTERAKSI UI
# ==========================================

## Dipanggil saat kursor mouse memasuki area kartu di tangan.
@warning_ignore("unused_signal")
signal card_hovered(card_ui: CardUI)

## Dipanggil saat kartu dengan target spesifik (SINGLE_ENEMY) ditarik melewati batas dan mulai membidik musuh.
@warning_ignore("unused_signal")
signal card_aim_started(card_ui: CardUI)

## Dipanggil saat pemain batal membidik atau melepaskan kartu bidikan.
@warning_ignore("unused_signal")
signal card_aim_ended(card_ui: CardUI)

## Dipanggil saat kartu valid dilepaskan di area drop battlefield dan efeknya dieksekusi.
@warning_ignore("unused_signal")
signal card_played(card: Card)

## Dipanggil saat pemain mulai menyeret kartu dari tangan (transisi ke status DRAGGING).
@warning_ignore("unused_signal")
signal card_drag_started(card_ui: CardUI)

## Dipanggil saat pemain melepaskan atau membatalkan seretan kartu kembali ke posisi dasar.
@warning_ignore("unused_signal")
signal card_drag_ended(card_ui: CardUI)


# ==========================================
# EVENT TOOLTIP
# ==========================================

## Dipanggil saat mouse hover di atas kartu untuk memunculkan panel deskripsi tooltip.
@warning_ignore("unused_signal")
signal card_tooltip_requested(card: Card)

## Dipanggil saat kursor keluar dari kartu untuk menyembunyikan panel tooltip.
@warning_ignore("unused_signal")
signal tooltip_hide_requested


# ==========================================
# EVENT STATUS PEMAIN & GILIRAN
# ==========================================

## Dipanggil setelah seluruh kartu giliran berhasil ditarik secara visual ke tangan pemain.
@warning_ignore("unused_signal")
signal player_hand_drawn

## Dipanggil setelah satu kartu giliran ditarik
@warning_ignore("unused_signal")
signal card_drawn

## Dipanggil setelah semua kartu di tangan selesai dibuang ke tumpukan buangan (discard pile).
@warning_ignore("unused_signal")
signal player_hand_discarded

## Dipanggil setiap kali satu kartu dibuang ke discard pile (untuk SFX per-kartu).
@warning_ignore("unused_signal")
signal card_discarded

## Dipanggil saat fase giliran pemain resmi dimulai (setelah musuh selesai bertindak).
@warning_ignore("unused_signal")
signal player_turn_started

## Dipanggil saat pemain menekan tombol "End Turn" untuk mengakhiri gilirannya.
@warning_ignore("unused_signal")
signal player_turn_ended

## Dipanggil setiap kali terjadi perubahan jumlah mana milik pemain.
@warning_ignore("unused_signal")
signal player_mana_changed(new_mana: int)

## Dipanggil saat Health pemain menyentuh angka 0 (Kondisi Game Over / Kalah).
@warning_ignore("unused_signal")
signal player_died


# ==========================================
# EVENT STATUS MUSUH & PERTEMPURAN
# ==========================================

@warning_ignore("unused_signal")
signal combat_start(Enemy:EnemyStats)

## Dipanggil saat fase giliran kelompok musuh dimulai.
@warning_ignore("unused_signal")
signal enemy_turn_started

## Dipanggil setelah seluruh musuh yang aktif selesai mengeksekusi aksinya.
@warning_ignore("unused_signal")
signal enemy_turn_ended

## Dipanggil saat seluruh musuh dalam pertempuran telah dikalahkan (Kondisi Menang).
@warning_ignore("unused_signal")
signal combat_victory


# ==========================================
# EVENT FEEDBACK AUDIO & UI UMUM
# ==========================================

## Sinyal umum yang dapat dipancarkan oleh komponen UI saat tombol umum ditekan.
@warning_ignore("unused_signal")
signal ui_button_clicked


# ==========================================
# EVENT EKSPLORASI & PROGRESSI LABIRIN
# ==========================================

## Dipanggil saat scene berpindah ke mode exploration
@warning_ignore("unused_signal")
signal exploration_start

## Dipanggil saat lantai berubah (lantai baru dinaiki).
@warning_ignore("unused_signal")
signal floor_changed(current_floor: int, max_floor: int)

## Dipanggil saat jumlah ruangan yang dijelajahi pada lantai saat ini berubah.
@warning_ignore("unused_signal")
signal room_exploration_changed(current: int, required_min: int)

## Dipanggil saat pemain menyelesaikan lantai maksimum (mencapai atap labirin / boss akhir).
@warning_ignore("unused_signal")
signal dungeon_completed

## Dipanggil saat ruangan yang di-forfeit di-reshuffle ke lantai masa depan.
@warning_ignore("unused_signal")
signal room_reshuffled(from_floor: int, to_floor: int, target_slot: int, room_data: RoomData, overwritten_room: RoomData)

## Dipanggil saat status ketersediaan forfeit berubah pada pemain di lantai aktif.
@warning_ignore("unused_signal")
signal forfeit_state_changed(can_forfeit: bool, remaining_forfeits: int)
