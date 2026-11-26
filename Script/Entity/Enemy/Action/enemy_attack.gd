# enemy_attack.gd
class_name EnemyAttack
extends EnemyAction

@export var damage: int = 6

func get_intent_value(p_enemy: Enemy = null) -> String:
	var active_enemy: Enemy = p_enemy if p_enemy else enemy
	var attacker_stats = active_enemy.stats if active_enemy else null
	var receiver_stats = null
	var p = target
	if not p and active_enemy and active_enemy.is_inside_tree():
		var players = active_enemy.get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			p = players[0]
	if p:
		if "character_stats" in p:
			receiver_stats = p.character_stats
		elif "stats" in p:
			receiver_stats = p.stats
				
	var final_damage = DamageCalculator.calculate_damage(damage, attacker_stats, receiver_stats)
	return str(final_damage)

func perform_action(p_enemy: Enemy, player: Node) -> void:
	Events.enemy_attack_used.emit()
	# 1. Tentukan formula aturan permainan yang dieksekusi saat benturan fisik
	var impact_logic = func():
		if player and is_instance_valid(player):
			var attacker_stats = p_enemy.stats
			var receiver_stats = player.character_stats if "character_stats" in player else (player.stats if "stats" in player else null)
			var final_damage = DamageCalculator.calculate_damage(damage, attacker_stats, receiver_stats)
			player.take_damage(final_damage)
	
	# 2. Perintahkan musuh mengeksekusi koreografinya dan tunggu sampai selesai
	await p_enemy.play_attack_animation(Vector2.LEFT * 45, impact_logic)
	
	# 3. Lapor ke Turn Manager bahwa giliran sudah beres
	enemy_action_completed.emit()
