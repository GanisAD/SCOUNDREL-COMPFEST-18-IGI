# charge_effect.gd
class_name ChargeEffect
extends Effect

@export var amount: int = 4

func execute(targets: Array[Node], player: Node = null) -> void:
	var exec_targets = targets if not targets.is_empty() else ([player] if player else [])
	
	for target in exec_targets:
		if not target:
			continue
		var target_stats: Resource = null
		if "character_stats" in target and target.character_stats:
			target_stats = target.character_stats
		elif "stats" in target and target.stats:
			target_stats = target.stats
			
		if target_stats and "charge_stacks" in target_stats:
			target_stats.charge_stacks += amount