class_name PotionUI
extends Control

signal potion_clicked(slot_index: int)

@export var potion: PotionData : set = _set_potion
@export var quantity: int = 1 : set = _set_quantity

var slot_index: int = -1
var slot_data: SlotData : set = _set_slot_data

@onready var icon_rect: TextureRect = $IconRect
@onready var quantity_label: Label = get_node_or_null("QuantityLabel")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	_update_ui()

func _set_slot_data(value: SlotData) -> void:
	slot_data = value
	if slot_data:
		potion = slot_data.item_data as PotionData
		quantity = slot_data.quantity
	else:
		potion = null
		quantity = 0

func _set_potion(value: PotionData) -> void:
	potion = value
	if not is_node_ready():
		await ready
	_update_ui()

func _set_quantity(value: int) -> void:
	quantity = value
	if not is_node_ready():
		await ready
	_update_ui()

func _update_ui() -> void:
	if not is_node_ready():
		return
		
	if potion and potion.icon:
		if icon_rect:
			icon_rect.texture = potion.icon
		visible = true
		tooltip_text = "%s\n%s" % [potion.name, potion.description]
	else:
		if icon_rect:
			icon_rect.texture = null
		visible = false
		tooltip_text = ""
		
	if quantity_label:
		if quantity > 1:
			quantity_label.text = "x%d" % quantity
			quantity_label.visible = true
		else:
			quantity_label.visible = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		accept_event()
		use_potion()

func use_potion() -> void:
	potion_clicked.emit(slot_index)
	var events = get_node_or_null("/root/Events")
	if events and events.has_signal("ui_button_clicked"):
		events.ui_button_clicked.emit()
	var ph = get_node_or_null("/root/PlayerHandler")
	if ph and slot_index >= 0:
		ph.use_potion(slot_index)

func _on_mouse_entered() -> void:
	modulate = Color(1.25, 1.25, 1.25)

func _on_mouse_exited() -> void:
	modulate = Color(1.0, 1.0, 1.0)
