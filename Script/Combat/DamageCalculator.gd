# damage_calculator.gd
class_name DamageCalculator
extends RefCounted

## Nilai modifier konstan per stack
const STRENGTH_MODIFIER_PER_STACK: float = 0.25  # +25%
const WEAKENED_MODIFIER_PER_STACK: float = 0.10  # -10%

static func calculate_damage(base_damage: int, attacker_stats: CharacterStats, _receiver_stats: EnemyStats) -> int:
	var modified_damage: float = base_damage

	if attacker_stats:
		var strength_multiplier: float = 1.0 + (attacker_stats.strength_stacks * STRENGTH_MODIFIER_PER_STACK)
		var weakened_multiplier: float = 1.0 - (attacker_stats.weakened_stacks * WEAKENED_MODIFIER_PER_STACK)
		
		# PRINT UNTUK CHECK MATEMATIKANYA
		print("--- PROSES KALKULASI DAMAGE ---")
		print("Damage Dasar: ", base_damage)
		print("Stack Strength Terbaca: ", attacker_stats.strength_stacks)
		print("Multiplier Strength: ", strength_multiplier)
		
		modified_damage *= strength_multiplier
		modified_damage *= max(0.1, weakened_multiplier)
		
		print("Hasil Sebelum Pembulatan: ", modified_damage)
		print("Hasil Akhir (Dibulatkan): ", max(0, roundi(modified_damage)))
		print("--------------------------------")
			
	return max(0, roundi(modified_damage))
