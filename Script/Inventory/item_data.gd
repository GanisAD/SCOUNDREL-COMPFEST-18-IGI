# item_data.gd (Resource)
class_name ItemData
extends Resource

@export var id: String
@export var name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var is_stackable: bool = false
@export var max_stack_size: int = 1
