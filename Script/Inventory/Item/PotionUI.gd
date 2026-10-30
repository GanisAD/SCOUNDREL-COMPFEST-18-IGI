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
	if not icon_rect:
		return
		
	if potion and potion.icon:
		icon_rect.texture = potion.icon
		visible = true
	else:
		icon_rect.texture = null
		visible = false