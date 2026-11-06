
extends Control

@onready var pause_panel = $Panel
@onready var pause_button = $HBoxContainer/Button

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_panel.hide()
	pause_button.show()
	get_tree().paused = false

# Tombol Pause
func _on_button_pressed():
	pause_panel.show()
	pause_button.hide()
	get_tree().paused = true

# Tombol Resume
func _on_resume_pressed():
	get_tree().paused = false
	pause_panel.hide()
	pause_button.show()

# Tombol Restart
func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

# Tombol Quit
func _on_quit_pressed():
	get_tree().paused = false
	get_tree().quit()
