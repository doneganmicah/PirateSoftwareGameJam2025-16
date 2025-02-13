extends Enemy

var hitting = false
var attack_cooled = true

@export var cfg_enemy_type : ENEMY_TYPES = ENEMY_TYPES.PLACEHOLDER
@export var cfg_enemy_act : ENEMY_ACTIVITIES = ENEMY_ACTIVITIES.DEFAULT
@export var cfg_enemy_patrol : ENEMY_PATROLS = ENEMY_PATROLS.DEFAULT

@export var patrol_speed = 150
@export var chase_speed = 300

func _ready() -> void:
	
	set_physics_process(false)
	call_deferred("enemies_setup")
	
	print("Setting up enemy")
	_initialize_enemy(cfg_enemy_type, cfg_enemy_act, 0, cfg_enemy_patrol)

func enemies_setup():
	# Skip the first frame to prevent race condition before nav server syncs
	await get_tree().physics_frame
	set_physics_process(true)
	
func _physics_process(delta: float) -> void:
	if not is_alive: return
	# See which activity the enemy is currently doing
	match enemy_activity:
		# The enemy is currently patroling and hasn't spotted the player
		ENEMY_ACTIVITIES.PATROLING:
			# Get the navigation vectors for their patrol type
			velocity = await get_patroling_vector() * patrol_speed
		# The enemy is currently pursuing the player.
		ENEMY_ACTIVITIES.ATACKING:
			velocity = get_attacking_vector(player) * chase_speed
		# The enemy is attacking the player.
		ENEMY_ACTIVITIES.HITTING:
			if(not hitting && attack_cooled):
				velocity = get_attacking_vector(player) * enemy_speed
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
				velocity = get_attacking_vector(player) * enemy_speed
			else:
				velocity = Vector2.ZERO
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
		enemy_activity = ENEMY_ACTIVITIES.ATACKING
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
	print("attacking Player")
	if(enemy_activity == ENEMY_ACTIVITIES.ATACKING):
		enemy_activity = ENEMY_ACTIVITIES.HITTING
	pass

# The player left the enemy's effective attack range.
# Called by the body left signal attached to the Melee Attack Effective Area2D.
func _player_left_attack_range(body: Node2D) -> void:
	if(not body.is_in_group("player")): return
	enemy_activity = ENEMY_ACTIVITIES.ATACKING
