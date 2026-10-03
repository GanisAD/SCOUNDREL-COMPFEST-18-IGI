# enemy_attack.gd
class_name EnemyAttack
extends EnemyAction

@export var damage: int = 6

func get_intent_value(enemy: Enemy = null) -> String:
	var attacker_stats = enemy.stats if enemy else null
	var receiver_stats = null
	if enemy and enemy.is_inside_tree():
		var players = enemy.get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			var p = players[0]
			if "character_stats" in p:
				receiver_stats = p.character_stats
			elif "stats" in p:
				receiver_stats = p.stats
				
	var final_damage = DamageCalculator.calculate_damage(damage, attacker_stats, receiver_stats)
	return str(final_damage)

func perform_action(enemy: Enemy, player: PlayerHandler) -> void:
	# 1. Tentukan formula aturan permainan yang dieksekusi saat benturan fisik
	var impact_logic = func():
		if player and is_instance_valid(player):
			var attacker_stats = enemy.stats
			var receiver_stats = player.character_stats
			var final_damage = DamageCalculator.calculate_damage(damage, attacker_stats, receiver_stats)
			player.take_damage(final_damage)
	
	# 2. Perintahkan musuh mengeksekusi koreografinya dan tunggu sampai selesai
	await enemy.play_attack_animation(Vector2.LEFT * 45, impact_logic)
	
	# 3. Lapor ke Turn Manager bahwa giliran sudah beres
	enemy_action_completed.emit()
