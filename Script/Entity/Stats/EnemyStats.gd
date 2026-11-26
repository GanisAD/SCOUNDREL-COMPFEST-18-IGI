class_name EnemyStats
extends Stats

# Properti spesifik yang hanya dimiliki oleh musuh
@export var enemy_name: String = "Unknown Enemy"

@export var strength_stacks: int = 0
## Jumlah stack Weakened yang dimiliki (Default 0)
@export var weakened_stacks: int = 0

# (Opsional) Scene AI (EnemyActionPicker) khusus untuk musuh ini jika di-spawn dari base scene
@export var ai: PackedScene

# Override fungsi create_instance untuk memastikan tipe kembaliannya (EnemyStats)
# dan mereset nilai saat musuh di-spawn ke dalam battle scene.
func create_instance() -> Resource:
	var instance: EnemyStats = self.duplicate()
	
	# Pastikan nilai ini sinkron dengan variabel internal di stats.gd kamu
	instance.health = max_health 
	instance.block = 0
	
	return instance
