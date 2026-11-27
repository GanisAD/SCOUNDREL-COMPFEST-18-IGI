extends Control

@onready var play_button = $Panel/VBoxContainer/VBoxContainer/Play
@onready var credit_button = $Panel/VBoxContainer/VBoxContainer/Credit
@onready var quit_button = $Panel/VBoxContainer/VBoxContainer/Quit


func _ready():
	play_button.pressed.connect(_on_play_pressed)
	credit_button.pressed.connect(_on_credit_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	GameManager.start_new_run()
	SceneManager.change_scene(SceneManager.SceneID.EXPLORE)

func _on_credit_pressed():
	print("Credit ditekan")
	# Nanti tampilkan informasi pembuat game


func _on_quit_pressed():
	get_tree().quit()
