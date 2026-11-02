class_name DebuffUI
extends Control

@export var debuff: DebuffData : set = _set_debuff
@export var duration: int = 0 : set = _set_duration

var slot_data: SlotData : set = _set_slot_data

@onready var icon_rect: TextureRect = $IconRect
@onready var duration_label: Label = get_node_or_null("DurationLabel")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	_update_ui()

func _set_slot_data(value: SlotData) -> void:
	slot_data = value
	if slot_data:
		debuff = slot_data.item_data as DebuffData
		duration = slot_data.quantity
	else:
		debuff = null
		duration = 0

func _set_debuff(value: DebuffData) -> void:
	debuff = value
	if not is_node_ready():
		await ready
	_update_ui()

func _set_duration(value: int) -> void:
	duration = value
	if not is_node_ready():
		await ready
	_update_ui()

func _update_ui() -> void:
	if not is_node_ready():
		return
		
	if debuff and debuff.icon:
		if icon_rect:
			icon_rect.texture = debuff.icon
		visible = true
		
		var duration_text = "%d pertempuran tersisa" % duration
		tooltip_text = "%s (%s)\n%s" % [debuff.name, duration_text, debuff.description]
	else:
		if icon_rect:
			icon_rect.texture = null
		visible = false
		tooltip_text = ""
		
	if duration_label:
		if duration > 0:
			duration_label.text = str(duration)
			duration_label.visible = true
		else:
			duration_label.text = ""
			duration_label.visible = false

func _on_mouse_entered() -> void:
	modulate = Color(1.25, 1.25, 1.25)

func _on_mouse_exited() -> void:
	modulate = Color(1.0, 1.0, 1.0)
