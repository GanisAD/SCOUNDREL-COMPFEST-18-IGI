extends Stats
class_name CharacterStats 

@export_group("Player Mechanics")
@export var max_mana: int = 3 
@export var cards_per_turn: int = 5 
@export var deck: CardPile #Dependensi ke tumpukan dek awal pemain 

@export_group("Player Damage Modifier")
## Jumlah stack Strength yang dimiliki (Default 0)
@export var strength_stacks: int = 0
## Jumlah stack Weakened yang dimiliki (Default 0)
@export var weakened_stacks: int = 0

var mana: int : set = set_mana 

func set_mana(value: int) -> void:
	mana = clamp(value, 0, max_mana) 
	stats_changed.emit() 

# Dipanggil oleh player_handler.gd di setiap awal turn pemain 
func reset_mana() -> void:
	mana = max_mana
