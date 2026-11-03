# scene_manager.gd
class_name SceneManagerNode
extends CanvasLayer

## SceneManager (Autoload: SceneManager)
##
## Pusat routing & transisi scene untuk ALTAR-52.
## Menangani transisi visual (fade) dan mencegah hardcoded path di script gameplay.

enum SceneID {
	NONE,
	EXPLORE,
	ROOM_EVENT,
	COMBAT,
	# Siap diekspansi untuk alur game berikutnya
	MAIN_MENU,
	GAME_OVER,
	VICTORY,
}

const SCENE_PATHS: Dictionary = {
	SceneID.EXPLORE: "res://Scene/explore.tscn",
	SceneID.ROOM_EVENT: "res://Scene/Components/room_event.tscn",
	SceneID.COMBAT: "res://Scene/combat.tscn",
}

signal transition_started(target_scene: SceneID)
signal scene_loaded(new_scene: SceneID)
signal transition_finished(current_scene: SceneID)

@onready var overlay: ColorRect = get_node_or_null("Overlay")
@onready var anim_player: AnimationPlayer = get_node_or_null("AnimationPlayer")

var current_scene_id: SceneID = SceneID.NONE
var _is_transitioning: bool = false

func _ready() -> void:
	_ensure_nodes()
	# Pastikan saat game mulai, overlay transparan dan tidak menangkap klik mouse
	if overlay:
		overlay.color = Color(0, 0, 0, 0)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ensure_nodes() -> void:
	if overlay == null:
		overlay = get_node_or_null("Overlay")
	if anim_player == null:
		anim_player = get_node_or_null("AnimationPlayer")

## Memulai perpindahan ke scene target dengan animasi transisi
func change_scene(target: SceneID, animation_name: String = "fade_to_black") -> void:
	_ensure_nodes()
	if _is_transitioning:
		push_warning("SceneManager: Pergantian scene sedang berjalan, permintaan diabaikan.")
		return
		
	if not SCENE_PATHS.has(target):
		push_error("SceneManager: SceneID %s tidak terdaftar di SCENE_PATHS!" % str(target))
		return
		
	var target_path: String = SCENE_PATHS[target]
	_is_transitioning = true
	
	# Blokir interaksi mouse pemain selama transisi
	if overlay:
		overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	transition_started.emit(target)
	
	# 1. Mainkan animasi fade to black
	if anim_player and anim_player.has_animation(animation_name):
		anim_player.play(animation_name)
		await anim_player.animation_finished
	elif overlay:
		# Fallback tween jika animasi tidak tersedia
		var tween = create_tween()
		tween.tween_property(overlay, "color:a", 1.0, 0.3)
		await tween.finished
		
	# 2. Ganti scene di SceneTree
	var err = get_tree().change_scene_to_file(target_path)
	if err != OK:
		push_error("SceneManager: Gagal memuat scene di path %s (Error code: %d)" % [target_path, err])
		_is_transitioning = false
		if overlay:
			overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return
		
	# 3. Tunggu satu frame agar node pada scene baru selesai _ready()
	await get_tree().process_frame
	current_scene_id = target
	scene_loaded.emit(target)
	
	# 4. Fade in (buka kembali layar)
	if anim_player and anim_player.has_animation(animation_name):
		anim_player.play_backwards(animation_name)
		await anim_player.animation_finished
	elif overlay:
		var tween = create_tween()
		tween.tween_property(overlay, "color:a", 0.0, 0.3)
		await tween.finished
		
	# 5. Buka kembali kuncian input
	if overlay:
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_transitioning = false
	transition_finished.emit(target)

## Helper untuk mereload scene yang sedang aktif saat ini
func reload_current_scene(animation_name: String = "fade_to_black") -> void:
	if current_scene_id != SceneID.NONE:
		change_scene(current_scene_id, animation_name)
	else:
		get_tree().reload_current_scene()
