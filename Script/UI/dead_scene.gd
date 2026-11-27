extends Control

@onready var pause_panel = $Panel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().paused = false

# Tombol Restart
func _on_restart_pressed():
	get_tree().paused = false
	GameManager.start_new_run()
	SceneManager.change_scene(SceneManager.SceneID.EXPLORE)

# Tombol Quit
func _on_quit_pressed():
	get_tree().paused = false
	SceneManager.change_scene(SceneManager.SceneID.MAIN_MENU)
