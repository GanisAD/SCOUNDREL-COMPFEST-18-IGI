# enemy_attack.gd
class_name EnemyAttack
extends EnemyAction

@export var damage: int = 6

func perform_action(enemy: Enemy, player: PlayerHandler) -> void:
	# 1. Logika Mekanik Game: Kurangi HP Player
	
	var attacker_stats = enemy.stats
	var receiver_stats = player.character_stats
	
	var final_damage = DamageCalculator.calculate_damage(damage, attacker_stats, receiver_stats)
	
	player.take_damage(final_damage)
	
	# 2. Logika Visual/Animasi (Opsional)
	# Di sini kamu bisa menambahkan Tween untuk membuat Sprite musuh maju-mundur,
	# memicu animasi pukulan, atau memutar sound effect (SFX).
	var tween = create_tween()
	var original_pos = enemy.global_position
	
	# Efek visual musuh menerjang maju ke arah player
	tween.tween_property(enemy, "global_position", player.global_position - Vector2(50, 0), 0.2)
	tween.tween_property(enemy, "global_position", original_pos, 0.2).set_delay(0.1)
	
	# 3. Selesaikan Aksi: Tunggu tween selesai baru pancarkan sinyal tamat
	await tween.finished
	enemy_action_completed.emit()
