extends Level


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _player_entered_ending(body: Node2D) -> void:
	if (body.is_in_group("player")):
		end_level(Globals.scenes.test_level)
