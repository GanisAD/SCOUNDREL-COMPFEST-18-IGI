class_name EnemyStats
extends Stats

# Properti spesifik yang hanya dimiliki oleh musuh
@export var enemy_name: String = "Unknown Enemy"

# (Opsional) Tempat penampung untuk sistem AI/Intent di masa depan
# @export var ai: EnemyAI 

# Override fungsi create_instance untuk memastikan tipe kembaliannya (EnemyStats)
# dan mereset nilai saat musuh di-spawn ke dalam battle scene.
func create_instance() -> Resource:
	var instance: EnemyStats = self.duplicate()
	
	# Pastikan nilai ini sinkron dengan variabel internal di stats.gd kamu
	instance.health = max_health 
	instance.block = 0
	
	return instance
