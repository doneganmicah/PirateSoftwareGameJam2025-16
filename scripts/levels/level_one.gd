extends Level
@onready var animation_player: AnimationPlayer = $LevelHandler/AnimationPlayer


func _ready() -> void:
	Signals.player_died.connect(reset)
	# doing this here but not because want to fill the defaults
	player.ringSize = Globals.player_ring_size
	player.health = Globals.player_health
	AudioManager.play_music("Good_init", 2)

func _player_entered_ending(body: Node2D) -> void:
	if (body.is_in_group("player")):
		end_level(Globals.scenes.test_level)

func reset():
	Globals.game_controller.change_2d_scene(Scenes.level_one)
