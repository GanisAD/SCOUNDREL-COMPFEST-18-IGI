# enemy_block.gd
class_name EnemyBlock
extends EnemyAction

@export var block_amount: int = 5

func perform_action(enemy: Enemy, player: PlayerHandler) -> void:
	# 1. Aturan Gameplay: Tambahkan nilai block ke stats musuh
	enemy.add_block(block_amount)
	
	# 2. Delegasi Visual: Tunggu musuh menyelesaikan animasi bertahannya
	await enemy.play_block_animation()
	
	# 3. Lapor ke Turn Manager
	enemy_action_completed.emit()
