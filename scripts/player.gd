extends CharacterBody2D
class_name Player

const SPEED = 300.0

var health: int = 3:
	get: return health
	set(value): health = maxi(0, value)
var heartsList: Array[TextureRect]

@onready var sporeRing = $"Area2D"

@export var playerAnimation: AnimatedSprite2D

func _ready() -> void:
	var heartsContainer = $"../HealthBar/HBoxContainer"
	
	for child in heartsContainer.get_children():
		heartsList.append(child)
	
	# Set initial state of health bar
	update_health_visual()

func _physics_process(delta: float) -> void:
	
	# Get bodies interacting with the spore ring
	var bodies = sporeRing.get_overlapping_bodies()
	
	# Check which bodies are enemies
	for body in bodies:
		if (body.name.contains("enemy_test")): # Hard-coded for now, will set to enemy class or smth
			print("Enemy Spored")
	
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
	print("Taking damage")
	# Visual Hit Indication
	# Spoors?
	health -= damage_amount	
	# Adjust Health Visual
	update_health_visual()
	if(health <= 0):
		has_died()
	return	
	
# The player has died	
func has_died():
	# TODO: Implement death handling
	print("ded")
	pass

func update_health_visual():
	for i in range(heartsList.size()):
		if i < health:
			heartsList[i].get_child(0).play("full_heart")
		else:
			heartsList[i].get_child(0).play("empty_heart")
		# Make furthest right heart pulse
		if i == health - 1:
			heartsList[i].get_child(0).play("full_heart_pulse")
