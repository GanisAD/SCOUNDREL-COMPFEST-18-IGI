class_name potionContainer
extends HBoxContainer

@export var potion_ui_scene : PackedScene
var inventory : InventoryData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.combat_start.connect(add_potion_to_container)
	PlayerHandler._potionContainer = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func add_potion_to_container(potion_data: PotionData) -> void:
	if not potion_ui_scene:
		push_error("Hand: card_ui_scene belum di-assign di Inspector!")
		return
		
	# 1. Lahirkan instance UI kartu baru
	var potion_ui = potion_ui_scene.instantiate() as PotionUI
	if not potion_ui:
		return
		
	# 3. Masukkan ke dalam container tangan ini
	add_child(potion_ui)
	
	# 4. Suntikkan data resource kartunya
	potion_ui_scene.potion = potion_data
	
	
