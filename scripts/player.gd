extends CharacterBody2D
class_name Player

const SPEED = 300.0
const MAX_RING_SIZE = 10
const MIN_RING_SIZE = 1

var health: int = 3:
	get: return health
	set(value): health = maxi(0, value)
var ringSize: int = 1: # To set the ring size, call set_ring_size(int between min and max)
	get: return ringSize
	set(value): ringSize = clamp(value, MIN_RING_SIZE, MAX_RING_SIZE)
var heartsList: Array[TextureRect]

@onready var sporeRing = $SporeRing
@onready var ringBody = $SporeRing/CollisionShape2D
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
	if (Input.is_action_just_pressed("ui_home")):
		set_ring_visibility(true)
	elif (Input.is_action_just_pressed("ui_end")):
		set_ring_visibility(false)
	# REMOVE LATER: Tab and Shift Tab can be used to adjust ring size for testing
	if (Input.is_action_just_pressed("ui_text_dedent")):
		print("Ring Decrease")
		ringSize -= 1
	elif (Input.is_action_just_pressed("ui_text_indent")):
		print("Ring Increase")
		ringSize += 1
	
	# Update size of spore ring
	set_ring_size(ringSize)
	
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

func set_ring_size(size: int):
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
			body.take_damage(1.0)
