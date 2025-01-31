extends Control

var pressed = false
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	if(pressed): return
	pressed = true
	animation_player.play("mainmenu_play")
	await animation_player.animation_finished
	Globals.game_controller.change_gui_scene(Globals.scenes.opening_cutscene)
	self.queue_free()

func _on_quit_pressed() -> void:
	get_tree().quit()
