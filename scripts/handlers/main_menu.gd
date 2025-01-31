extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	Globals.game_controller.change_2d_scene(Globals.scenes.level_one)
	self.queue_free()

func _on_quit_pressed() -> void:
	get_tree().quit()