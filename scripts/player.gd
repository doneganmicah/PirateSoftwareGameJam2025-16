extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var playerAnimation: AnimatedSprite2D

func _physics_process(delta: float) -> void:
	
	var direction := Input.get_vector("player_left", "player_right", "player_up", "player_down")
	
	if direction:
		# Sprite Orientation
		if direction.x > 0:
			playerAnimation.flip_h = false
		elif direction.x < 0:
			playerAnimation.flip_h = true
		
		playerAnimation.play("move")
		
		velocity = direction * SPEED
	else:
		playerAnimation.play("idle")
		
		velocity = Vector2.ZERO
	
	move_and_slide()
