# debuff_data.gd
class_name DebuffData
extends ItemData

@export_group("Debuff Mechanics")
## Durasi debuff dalam hitungan jumlah pertempuran (battle)
@export var duration_in_battles: int = 5

## Pengurangan Max HP pemain dalam persen (contoh 20.0 = 20%)
@export_range(0.0, 100.0, 0.5) var max_hp_reduction_percent: float = 20.0

## Tambahan Strength stack selama debuff aktif
@export var strength_bonus: int = 1

## Efek modular opsional jika ingin menggunakan Effect component
@export var effects: Array[Effect] = []

## Menerapkan efek debuff ke stats karakter pemain di awal pertempuran
func apply_to_stats(stats: CharacterStats) -> void:
	if not stats:
		return
	
	# 1. Pengurangan Max HP pemain sesuai persentase
	if max_hp_reduction_percent > 0.0:
		var hp_reduction: int = int(round(stats.max_health * (max_hp_reduction_percent / 100.0)))
		stats.max_health = maxi(1, stats.max_health - hp_reduction)
		if stats.health > stats.max_health:
			stats.health = stats.max_health
	
	# 2. Tambahan Strength stack
	if strength_bonus != 0:
		stats.strength_stacks += strength_bonus
	
	# 3. Eksekusi effects tambahan jika ada
	for effect in effects:
		if effect:
			effect.execute([], null)
	
	stats.stats_changed.emit()
	print("Debuff '%s' diterapkan: Max HP berkurang %.1f%%, Strength bertambah +%d" % [name, max_hp_reduction_percent, strength_bonus])
