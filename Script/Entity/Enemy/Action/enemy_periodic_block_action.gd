## Aksi kondisional musuh yang memberikan pertahanan (Block) berulang setiap beberapa giliran.
## Digunakan oleh Golem untuk aksi spesial Triple Shield setiap 5 turn.
class_name EnemyPeriodicBlockAction
extends EnemyAction

@export var base_block: int = 6
@export var multiplier: int = 3
@export var turn_interval: int = 5

func is_conditional() -> bool:
	return true

func is_performable() -> bool:
	if not enemy or turn_interval <= 0:
		return false
	# Sinkron dengan update_intent() yang dipanggil sebelum giliran musuh dieksekusi:
	# saat turns_taken == 4, musuh sedang merencanakan giliran ke-5.
	return (enemy.turns_taken + 1) % turn_interval == 0

func get_intent_value(_enemy: Enemy = null) -> String:
	return "%dx%d" % [base_block, multiplier]

func perform_action(p_enemy: Enemy, _player: Node) -> void:
	for i in range(multiplier):
		if not is_instance_valid(p_enemy) or not p_enemy.is_inside_tree():
			break
		Events.enemy_shield_used.emit()
		p_enemy.add_block(base_block)
		await p_enemy.play_block_animation()
	
	enemy_action_completed.emit()
