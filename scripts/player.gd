extends CharacterBody2D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var health: int = 3:
	get: return health
	set(value): health = maxi(0, value)

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

# Called when the player has received any damage
func receive_damage(damage_amount: int):
	# Visual Hit Indication
	# Spoors?
	health -= damage_amount
	# Adjust Health Visual
	if(health <= 0):
		has_died()
	return	
	
# The player has died	
func has_died():
	# TODO: Implement death handling
	pass
