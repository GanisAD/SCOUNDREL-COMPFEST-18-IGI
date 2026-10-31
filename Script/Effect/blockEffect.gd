# block_effect.gd
class_name blockEffect
extends Effect

@export var amount: int = 0

func execute(_targets: Array[Node], player: Node) -> void:
	Events.shield_used.emit()
	var target_player: Node = player
	if not target_player and Engine.has_singleton("PlayerHandler"):
		target_player = Engine.get_singleton("PlayerHandler")
		
	if target_player:
		if "character_stats" in target_player and target_player.character_stats:
			target_player.character_stats.block += amount
		elif "stats" in target_player and target_player.stats:
			target_player.stats.block += amount
