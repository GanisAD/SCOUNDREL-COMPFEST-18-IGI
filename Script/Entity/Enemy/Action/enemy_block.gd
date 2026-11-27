# enemy_block.gd
class_name EnemyBlock
extends EnemyAction

@export var block_amount: int = 5

func get_intent_value(_enemy: Enemy = null) -> String:
	return str(block_amount)

func perform_action(p_enemy: Enemy, _player: Node) -> void:
	Events.enemy_shield_used.emit()
	# 1. Aturan Gameplay: Tambahkan nilai block ke stats musuh
	p_enemy.add_block(block_amount)
	
	# 2. Delegasi Visual: Tunggu musuh menyelesaikan animasi bertahannya
	await p_enemy.play_block_animation()
	
	# 3. Lapor ke Turn Manager
	enemy_action_completed.emit()
