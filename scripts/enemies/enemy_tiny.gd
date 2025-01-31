extends Enemy

var hitting = false
var attack_cooled = true
var cooling = false
var can_hit = false
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

@export var cfg_enemy_type : ENEMY_TYPES = ENEMY_TYPES.PLACEHOLDER
@export var cfg_enemy_act : ENEMY_ACTIVITIES = ENEMY_ACTIVITIES.DEFAULT
@export var cfg_enemy_patrol : ENEMY_PATROLS = ENEMY_PATROLS.DEFAULT
@export var cfg_health = 3
@export var cfg_damage = 1
@export var cfg_speed = 300

@export var patrol_speed = 150
@export var chase_speed = 300
@export var steer_weight = 25

@onready var ray_cast_2d: RayCast2D = $RayCast2D

func _ready() -> void:
	
	set_physics_process(false)
	call_deferred("enemies_setup")
	
	print("Setting up enemy")
	_initialize_enemy(cfg_enemy_type, cfg_enemy_act, 0, cfg_enemy_patrol, cfg_health, cfg_damage, cfg_speed)

func enemies_setup():
	# Skip the first frame to prevent race condition before nav server syncs
	await get_tree().physics_frame
	set_physics_process(true)
	
func _physics_process(delta: float) -> void:
	if not is_alive: return
	# See which activity the enemy is currently doing
	var steering
	var direction = (player.global_position - ray_cast_2d.global_position).normalized()
	ray_cast_2d.target_position = direction * ray_cast_2d.target_position.length()
	
	match enemy_activity:
		# The enemy is currently patroling and hasn't spotted the player
		ENEMY_ACTIVITIES.PATROLING:
			# Get the navigation vectors for their patrol type
			steering = ((await get_patroling_vector() * patrol_speed) - velocity) * steer_weight
			velocity = velocity + (steering * delta)
		# The enemy is currently pursuing the player.
		ENEMY_ACTIVITIES.ATACKING:
			steering = ((get_attacking_vector(player) * chase_speed) - velocity) * steer_weight
			velocity = velocity + (steering * delta)
		# The enemy is attacking the player.
		ENEMY_ACTIVITIES.HITTING:
			if(not hitting && attack_cooled):
				steering = ((get_attacking_vector(player) * 75) - velocity) * steer_weight
				velocity = velocity + (steering * delta)
				hitting = true
				attack_cooled = false
				await get_tree().create_timer(0.40).timeout
				for body in range_area.get_overlapping_bodies():
					if(body is not CharacterBody2D): continue
					# This code is botched and there has to be a better way to do it.
					if(body.is_in_group("player")):
						var player = body as Player
						player.receive_damage(enemy_damage)
						print("Hitting Player")
				hitting = false
				await get_tree().create_timer(1).timeout
				attack_cooled = true
			elif(attack_cooled == false):
				steering = ((get_attacking_vector(player) * chase_speed) - velocity) * steer_weight
				velocity = velocity + (steering * delta)
			else:
				velocity = Vector2.ZERO
				
	if velocity > Vector2(0.5,0.5) or velocity < Vector2(-0.5, -0.5):
		# Sprite Orientation
		if velocity.x > 0:
			animated_sprite_2d.flip_h = false
		elif velocity.x < 0:
			animated_sprite_2d.flip_h = true
		
		animated_sprite_2d.play("gobbie_walk")
		cpu_particles_2d.emitting = true
	else:
		cpu_particles_2d.emitting = false
		animated_sprite_2d.play("gobbie_idle")
	
	move_and_slide()


################################################################################
##                       Callbacks and other Callables                        ##
################################################################################
# The player entered the enemy's range of vision.
# Called by the body entered signal attached to the Vision Area2D.
func _player_entered_vision(body: Node2D) -> void:
	if(not body.is_in_group("player")): return
	print("spotted Player")
	if(enemy_activity == ENEMY_ACTIVITIES.PATROLING):
		enemy_activity = ENEMY_ACTIVITIES.HITTING
	return

# The player left the enemy's range of vision.
# Called by the body left signal attached to the Vision Area2D.
func _player_left_vision(body: Node2D) -> void:
	# not implimented since the player never loses agression.
	pass

# The player entered the enemy's effective attack range.
# Called by the body entered signal attached to the Melee Attack Effective Area2D.
func _player_entered_attack_range(body: Node2D) -> void:
	if(not body.is_in_group("player")): return
	if(enemy_activity == ENEMY_ACTIVITIES.ATACKING):
		enemy_activity = ENEMY_ACTIVITIES.HITTING

# The player left the enemy's effective attack range.
# Called by the body left signal attached to the Melee Attack Effective Area2D.
func _player_left_attack_range(body: Node2D) -> void:
	if(enemy_activity == ENEMY_ACTIVITIES.PATROLING): return
	if(not body.is_in_group("player")): return
	enemy_activity = ENEMY_ACTIVITIES.ATACKING
