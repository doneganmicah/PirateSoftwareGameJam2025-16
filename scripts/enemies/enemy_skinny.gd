extends Enemy

var hitting = false
var attack_cooled = true

@export var cfg_enemy_type : ENEMY_TYPES = ENEMY_TYPES.PLACEHOLDER
@export var cfg_enemy_act : ENEMY_ACTIVITIES = ENEMY_ACTIVITIES.DEFAULT
@export var cfg_enemy_patrol : ENEMY_PATROLS = ENEMY_PATROLS.DEFAULT
@export var cfg_health = 3
@export var cfg_damage = 1
@export var cfg_speed = 300

@onready var proj_node: Node = $ProjectilesLiveHere
@onready var projectile = load("res://scenes/prefabs/enemies/projectile.tscn")


@export var patrol_speed = 150
@export var chase_speed = 300
@export var steer_weight = 25

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
			if(not hitting):
				hitting = true
				var instance = projectile.instantiate()
				instance.global_position = self.global_position
				instance.direction = player.global_position - self.global_position 
				instance.node = proj_node
				proj_node.add_child.call_deferred(instance)
				instance.shot()
				await get_tree().create_timer(2).timeout
				hitting = false
			steering = ((get_attacking_vector(player) * 50) - velocity) * steer_weight
			velocity = velocity + (steering * delta)
				
	if velocity > Vector2(0.5,0.5) or velocity < Vector2(-0.5, -0.5):
		# Sprite Orientation
		if velocity.x > 0:
			animated_sprite_2d.flip_h = false
		elif velocity.x < 0:
			animated_sprite_2d.flip_h = true
		
			animated_sprite_2d.play("skinny_walk")
		else:
			animated_sprite_2d.play("skinny_idle")
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
