# apply_strength_effect.gd
class_name StrengthEffect
extends Effect

@export var stacks_to_add: int = 1
@export var target_self: bool = true

func execute(targets: Array[Node], player: Node) -> void:
	if target_self:
		if player and "character_stats" in player:
			player.character_stats.strength_stacks += stacks_to_add
	else:
		for target in targets:
			if target and "stats" in target:
				target.character_stats.strength_stacks += stacks_to_add
