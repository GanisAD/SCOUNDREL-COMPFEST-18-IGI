# potion_data.gd
class_name PotionData
extends ItemData

enum TargetType { SELF, SINGLE_ENEMY, ALL_ENEMIES }

@export_group("Potion Mechanics")
@export var target_type: TargetType = TargetType.SELF
@export var effects: Array[Effect] = [] # Memakai Effect Component yang sama seperti Kartu

## Menggunakan potion dengan target dan node player (opsional)
func use(targets: Array[Node] = [], player: Node = null) -> void:
	var final_targets: Array[Node] = targets.duplicate()
	var final_player: Node = player
	
	if not final_player and Engine.has_singleton("PlayerHandler"):
		final_player = Engine.get_singleton("PlayerHandler")
		
	if target_type == TargetType.SELF and final_targets.is_empty() and final_player:
		final_targets = [final_player]
		
	for effect in effects:
		if effect:
			effect.execute(final_targets, final_player)
			
	print("Potion: '%s' berhasil digunakan." % name)
