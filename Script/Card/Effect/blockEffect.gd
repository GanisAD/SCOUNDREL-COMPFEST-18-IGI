# damage_effect.gd
class_name blockEffect
extends Effect

@export var amount: int = 0

func execute(_targets: Array[Node], player: Node) -> void:
		# PlayerHandler biasanya memiliki akses ke character_stats-nya
		if player and "character_stats" in player:
			player.character_stats.block += amount
		#elif player and player.has_method("take_damage"): 
			## Atau sesuaikan dengan fungsi penambahan block di PlayerHandler Anda
			#player.character_stats.block += amount
