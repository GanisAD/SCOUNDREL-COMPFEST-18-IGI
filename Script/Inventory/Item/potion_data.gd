# potion_data.gd
class_name PotionData
extends ItemData

enum TargetType { SELF, SINGLE_ENEMY, ALL_ENEMIES }

@export_group("Potion Mechanics")
@export var target_type: TargetType = TargetType.SELF
@export var effects: Array[Effect] = [] # Memakai Effect Component yang sama seperti Kartu

func use(targets: Array[Node], player: Node) -> void:
	for effect in effects:
		if effect:
			effect.execute(targets, player)
