extends Level
@onready var animation_player: AnimationPlayer = $LevelHandler/AnimationPlayer


func _ready() -> void:
	Signals.player_died.connect(reset)
	# doing this here but not because want to fill the defaults
	player.ringSize = Globals.player_ring_size
	player.health = Globals.player_health

func _player_entered_ending(body: Node2D) -> void:
	if (body.is_in_group("player")):
		Signals.player_died.disconnect(reset)
		Globals.is_end = true
		end_level("ui_end")

func reset():
	player.health = 3
	Globals.player_health = 3
	Globals.game_controller.change_2d_scene(Scenes.level_three)
	
