class_name CardState
extends Node

# 1. Definisikan Enum untuk semua status yang ada
enum State { BASE, HOVER, CLICKED, DRAGGING, AIMING, RELEASED }

# 2. Sinyal transisi yang akan ditangkap oleh CardStateMachine
@warning_ignore("unused_signal")
signal transition_requested(from: CardState.State, to: CardState.State)

# 3. Variabel Export agar status bisa di-set di Inspector
@export var state: State

# 4. Referensi ke CardUI induk (akan disuntikkan oleh StateMachine)
var card_ui: CardUI

# 5. Fungsi Siklus Hidup (Lifecycle)
func enter() -> void:
	pass

func exit() -> void:
	pass

# 6. Fungsi Callback Input & Mouse
func on_input(_event: InputEvent) -> void:
	pass

func on_gui_input(_event: InputEvent) -> void:
	pass

func on_mouse_entered() -> void:
	pass

func on_mouse_exited() -> void:
	pass
