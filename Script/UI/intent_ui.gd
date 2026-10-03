# intent_ui.gd
class_name IntentUI
extends HBoxContainer

# Hubungkan komponen child di dalam scene UI lewat Onready
@onready var icon: TextureRect = $Icon
@onready var number: Label = $Number

func _ready() -> void:
	# Sembunyikan UI secara default saat pertempuran dimulai
	hide()

# Fungsi utama yang dipanggil oleh Enemy ketika rencana aksinya ditentukan atau diperbarui
func update_intent(intent_or_action: Variant, enemy: Enemy = null) -> void:
	if not intent_or_action:
		hide()
		return
		
	var intent_data: Intent = null
	var display_text: String = ""
	
	if intent_or_action is EnemyAction:
		intent_data = intent_or_action.intent
		display_text = intent_or_action.get_intent_value(enemy)
	elif intent_or_action is Intent:
		intent_data = intent_or_action
		display_text = intent_data.number
	else:
		hide()
		return
		
	if not intent_data:
		hide()
		return
		
	# 1. Update Ikon Visual
	if icon and intent_data.icon:
		icon.texture = intent_data.icon
		
	# 2. Update Label Angka (Damage/Shield)
	if number:
		if display_text.strip_edges() == "":
			# Sembunyikan label angka jika teksnya kosong (misal: saat Buff/Debuff)
			number.visible = false
		else:
			number.text = display_text
			number.visible = true
			
	# Tampilkan UI setelah data berhasil diperbarui
	show()

