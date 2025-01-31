extends RayCast2D

# Parent
@onready var enemy: CharacterBody2D = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(is_colliding()):
		if(get_collider() is Player):
			enemy.can_hit = true
			return
	enemy.can_hit = false
