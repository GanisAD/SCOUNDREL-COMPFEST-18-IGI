class_name healthEffect
extends Effect

@export var amount: int = 0

func execute(_targets: Array[Node], player: Node) -> void:
	var target_player: Node = player
	if not target_player and Engine.has_singleton("PlayerHandler"):
		target_player = Engine.get_singleton("PlayerHandler")
		
	if target_player:
		if "character_stats" in target_player and target_player.character_stats:
			target_player.character_stats.health += amount
		elif "stats" in target_player and target_player.stats:
			target_player.stats.health += amount
