class_name DamageEffect
extends Effect

@export var amount: int = 0
@export var repeats: int = 1 

func execute(targets: Array[Node], player: Node) -> void:
	var attacker_stats = null
	if player:
		if "character_stats" in player:
			attacker_stats = player.character_stats
		elif "stats" in player:
			attacker_stats = player.stats

	for i in range(repeats):
		for target in targets:
			if target and target.has_method("take_damage"):
				var receiver_stats = null
				if "character_stats" in target:
					receiver_stats = target.character_stats
				elif "stats" in target:
					receiver_stats = target.stats

				var final_damage = DamageCalculator.calculate_damage(amount, attacker_stats, receiver_stats)
				target.take_damage(final_damage)
