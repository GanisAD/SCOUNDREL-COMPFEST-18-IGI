class_name EnemyBlock
extends EnemyAction

@export var block_amount: int = 5

func perform_action(enemy: Enemy, player: PlayerHandler) -> void:
	# 1. Eksekusi penambahan block lewat fungsi yang baru kita buat di Enemy
	enemy.add_block(block_amount)
	
	# 2. Karena efek visual sederhana sudah ditangani oleh _play_block_effect() di Enemy,
	# kita bisa langsung menyudahi aksi ini agar turn manager lanjut ke musuh berikutnya.
	enemy_action_completed.emit()
