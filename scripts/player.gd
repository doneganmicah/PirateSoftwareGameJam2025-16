extends CharacterBody2D
class_name Player

const SPEED = 400.0
const MAX_RING_SIZE = 10
const MIN_RING_SIZE = 1
const MAX_HEALTH    = 3

var health: int = 3:
	get: return health
	set(value): health = clamp(value, 0, MAX_HEALTH)
var ringSize: int = 1: # To set the ring size, call set_ring_size(int between min and max)
	get: return ringSize
	set(value): ringSize = clamp(value, MIN_RING_SIZE, MAX_RING_SIZE)
var heartsList: Array[TextureRect]

var player_can_move = true
# if the ring is being animated right now
var drawing_ring = false

@onready var sporeRing = $SporeRing
@onready var ringBody: CollisionShape2D = $SporeRing/CollisionShape2D
@onready var timer = $Timer

@export var playerAnimation: AnimatedSprite2D
@export var sporeTickTimer: float

func _ready() -> void:
	var heartsContainer = $"../HealthBar/HBoxContainer"
	
	for child in heartsContainer.get_children():
		heartsList.append(child)
	
	# Set initial state of health bar
	update_health_visual()
	
	# Set timer tick speed and start
	timer.wait_time = sporeTickTimer
	timer.start()

func _physics_process(delta: float) -> void:
	# Update size of spore ring
	set_ring_size(ringSize)
	
	var direction := Input.get_vector("player_left", "player_right", "player_up", "player_down")
	
	if direction and player_can_move:
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

func can_move(value : bool):
	player_can_move = value


# Called when the player has received any damage
func receive_damage(damage_amount: int):
	print("Taking damage")
	# Visual Hit Indication
	# Spoors?
	health -= damage_amount	
	# Adjust Health Visual
	update_health_visual()
	playerAnimation.material = Globals.DAMAGE_FLASH
	await get_tree().create_timer(0.15).timeout
	playerAnimation.material = null
	ringSize += 2
	
	if(health <= 0):
		has_died()
	return	
	
# The player has died	
func has_died():
	# TODO: Implement death handling
	Signals.player_died.emit()
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

################################################################################
## Updated this to take in a target radius 
################################################################################
func set_ring_size(size: int):
	if(ringBody.scale != Vector2(size, size) and not drawing_ring):
		drawing_ring = true
		await get_tree().create_tween().tween_property(ringBody, "scale", Vector2(size,size), 0.30).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING).finished
		drawing_ring = false
	elif(not drawing_ring):
		ringBody.scale = Vector2(size, size)

func set_ring_visibility(show: bool):
	sporeRing.visible = show

func _on_timer_timeout() -> void:
	# Get bodies interacting with the spore ring
	var bodies = sporeRing.get_overlapping_bodies()
	
	# Check which bodies are enemies
	for body in bodies:
		if (body.is_in_group("enemy")):
			# Deal damage to enemy
			Globals.player_hurt_enemies += 1
			if(await body.take_damage(1.0)): Globals.player_killed_enemies += 1
