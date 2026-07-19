# intent_ui.gd
class_name IntentUI
extends HBoxContainer

# Hubungkan komponen child di dalam scene UI lewat Onready
@onready var icon: TextureRect = $Icon
@onready var number: Label = $Number

func _ready() -> void:
	# Sembunyikan UI secara default saat pertempuran dimulai
	hide()

# Fungsi utama yang dipanggil oleh Enemy ketika rencana aksinya berubah
func update_intent(intent_data: Intent) -> void:
	if not intent_data:
		hide()
		return
		
	# 1. Update Ikon Visual
	if icon and intent_data.icon:
		icon.texture = intent_data.icon
		
	# 2. Update Label Angka (Damage/Shield)
	if number:
		if intent_data.number.strip_edges() == "":
			# Sembunyikan label angka jika teksnya kosong (misal: saat Buff/Debuff)
			number.visible = false
		else:
			number.text = intent_data.number
			number.visible = true
			
	# Tampilkan UI setelah data berhasil diperbarui
	show()
