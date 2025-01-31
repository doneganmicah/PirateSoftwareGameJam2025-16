extends Level

func _ready() -> void:
	Signals.player_died.connect(reset)


func _player_entered_ending(body: Node2D) -> void:
	if (body.is_in_group("player")):
		end_level(Globals.scenes.test_level)

func reset():
	Globals.game_controller.change_2d_scene(Scenes.level_one)
