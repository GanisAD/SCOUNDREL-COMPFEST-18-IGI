# apply_weakened_effect.gd
class_name WeakenedEffect
extends Effect

@export var stacks_to_add: int = 1
@export var target_self: bool = false

func execute(targets: Array[Node], player: Node) -> void:
	if target_self:
		if player and "character_stats" in player:
			player.character_stats.weakened_stacks += stacks_to_add
	else:
		for target in targets:
			if target and "stats" in target:
				target.stats.weakened_stacks += stacks_to_add
