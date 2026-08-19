# damage_calculator.gd
class_name DamageCalculator
extends RefCounted

const STRENGTH_MODIFIER_PER_STACK: float = 0.25
const WEAKENED_MODIFIER_PER_STACK: float = 0.10

## Ubah tipe parameter menjadi 'Resource' agar bisa menerima CharacterStats maupun EnemyStats
static func calculate_damage(base_damage: int, attacker_stats: Resource, receiver_stats: Resource) -> int:
	var modified_damage: float = base_damage
	
	# === FASE PENYERANG (ATTACKER) ===
	if attacker_stats:
		# Ambil nilai stack HANYA JIKA properti tersebut ada di dalam stats, jika tidak anggap 0
		var str_stacks: int = attacker_stats.strength_stacks if "strength_stacks" in attacker_stats else 0
		var weak_stacks: int = attacker_stats.weakened_stacks if "weakened_stacks" in attacker_stats else 0
		
		# 1. Kalkulasi Strength
		var strength_multiplier: float = 1.0 + (str_stacks * STRENGTH_MODIFIER_PER_STACK)
		modified_damage *= strength_multiplier
		
		# 2. Kalkulasi Weakened
		var weakened_multiplier: float = 1.0 - (weak_stacks * WEAKENED_MODIFIER_PER_STACK)
		modified_damage *= max(0.1, weakened_multiplier)
			
	# === FASE PENERIMA (RECEIVER) ===
	if receiver_stats:
		# Ambil nilai Vulnerable (Rapuh) HANYA JIKA propertinya ada di stats penerima
		var vul_stacks: int = receiver_stats.vulnerable_stacks if "vulnerable_stacks" in receiver_stats else 0
		
		if vul_stacks > 0:
			modified_damage *= 1.5 # Contoh modifier damage masuk bertambah 50%
			
	return max(0, roundi(modified_damage))
