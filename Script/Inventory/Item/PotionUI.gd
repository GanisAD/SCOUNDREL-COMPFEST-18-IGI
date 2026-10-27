class_name PotionUI
extends Control

@export var potion: PotionData : set = _set_potion
@onready var icon_rect: TextureRect = $IconRect

func _set_potion(value: PotionData) -> void:
	potion = value
	if not is_node_ready():
		await ready
	_update_ui()

func _update_ui() -> void:
	if not potion:
		return
	
	if potion.icon:
		icon_rect.texture = potion.icon

