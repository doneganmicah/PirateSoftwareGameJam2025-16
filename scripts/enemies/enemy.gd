################################################################################
## This is the Enemy base class. It contains properties such as Health,       ##
## Ailments, and AI Goals.                                                    ##
## This class will be inherited by the actual enemy type class.               ##
################################################################################  
class_name Enemy
extends CharacterBody2D

################################################################################
##                             Constants & Enums                              ##
################################################################################
## Enumerators
# TODO: THESE WILL NEED TO BE CHANGED TO MATCH WHATEVER WE NEED THEM TOO
# Enemy Type is the child_class reference.
enum ENEMY_TYPES       {PLACEHOLDER, SLAP, PITCHFORK, CROSSBOW, NETCASTER} 
# Enemy Variant is for different skins.
enum ENEMY_VARIANTS    {DEFAULT, MUSHROOM_ONE, MUSHROOM_REDCAP, MUSHROOM_DOGE} 
# This is what the enemy's current objective is. (Default is NO_AI)
enum ENEMY_ACTIVITIES  {DEFAULT, PATROLING, ATACKING, HITTING}
# This is what the enemy's patrol looks like. (Default is similar to NO_AI)
enum ENEMY_PATROLS     {DEFAULT, PATH, AREA, GUARDING, SEARCH} 

## Constants
const MAX_HEALTH = 3 # The maximum amount of health for an enemy.
const MAX_DAMAGE = 1 # The maximum amount of damage an enemy can do.
const WAIT_TIME  = 2 # The amount of time for the enemy to wait at a point before moving to the next
const POI_DEADZONE = 10.0 # The tolerance for when an enemy arrives at a point in distance from it.
const DEFAULT_MASS = 1

################################################################################
##                                 Properties                                 ##
################################################################################
## Child Nodes
# Instance of Area2D where melee attack can hit
@onready var range_area: Area2D = $MeleeAttackEffectiveRange:
	get: return range_area
# Instance of the areas collision shape. Used to change the radius.
@onready var effective_attack_range: CollisionShape2D = $MeleeAttackEffectiveRange/CollisionShape2D:
	get: return effective_attack_range
# Instance of the Area2D where the enemy can detect Players.
@onready var vision_area: Area2D = $Vision
# Instance of the areas collisions shape. Used to change the effective vision range.
@onready var effective_vision_range: CollisionShape2D = $Vision/CollisionShape2D
# Instance of the Navigation Agent. Used to get the path finding for our mushroom enemies
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
# Instance of the sprite Renderer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D:
	get: return animated_sprite_2d
# Instance of the Control points node
@onready var control_points: Node = $ControlPoints



@export var player : Player
		
## Members
# This is the amount of health the enemy has, will be set by the child class.
var enemy_health : float:
	get: return enemy_health
	set(value): enemy_health = clamp(value, 0, MAX_HEALTH) 
# This is the amount of damage the enemy does, will be set by the child class.
var enemy_damage : int:
	get: return enemy_damage
	set(value): enemy_damage = clamp(value, 0, MAX_DAMAGE)
# The type of the enemy is determined by the child class.
var enemy_type : ENEMY_TYPES:
	get: return enemy_type
	set(value): enemy_type = value
# The enemy variant determines which enemy mushroom skin to wear.
var enemy_variant : ENEMY_VARIANTS:
	get: return enemy_variant
	set(value): enemy_variant = value
# The enemy activity is what the current AI objective is (see AI Objectives in GDD).
var enemy_activity : ENEMY_ACTIVITIES:
	get: return enemy_activity
	set(value): enemy_activity = value
# The enemy patrol type is what directs the enemies passive movement.
var enemy_patrol_type: ENEMY_PATROLS:
	get: return enemy_patrol_type
	set(value): enemy_patrol_type = value
# If the enemy has been sickened by spores, causing coughing and slower movement.
var is_spore_sick: bool:
	get: return is_spore_sick
	set(value): is_spore_sick = value
# This has nothing to do with his feelings of being alive, this particular guy didnt invest in the houseing market during 2008 not because of his hideous incompetence but because he is a mushroom and it is a well known fact that mushrooms can not make dealings regarding realestate, due to this fact his self of living is critically at a low point.
# If the enemy has died or not.
var is_alive : bool:
	get: return is_alive
	set(value): is_alive = value
# How fast the enemy can move.
var enemy_speed : int:
	get: return enemy_speed
	set(value): enemy_speed = value
# Used to give weight to the enemies steering.
var enemy_mass : int:
	get: return enemy_mass
	set(value): enemy_mass = value
	
	
## Pathing Variables
var normalized_dir_vectors = PathVectors.new()
var raycast_arrays : Array[bool]
var weighted_scalars = PathVectors.new() # uses the x value of vec2 as a scalar
var obstacles_scalars = PathVectors.new() # uses the x value of vec2 as a scalar
var calculated_choice = PathVectors.new()
# Current Point of Interest
var current_poi : Vector2
# Path switching
var path_switch: int = 0
# Area switching
var area_switch: int = 0
# Guard point
var guard_vector = Vector2(0,0)
# Holding for a second at the point of interest
var waiting = false
# Random Numbers
var rng = RandomNumberGenerator.new()

################################################################################
##                                 Functions                                  ##
################################################################################

################################################################################
## Fill out some variables to prevent uninitialized errors                    ##
################################################################################
func _init() -> void:
	normalized_dir_vectors.create_vector(Vector2(0,1), Vector2(1,1), Vector2(1,0), Vector2(1,-1), Vector2(0,-1), Vector2(-1,-1), Vector2(-1,0), Vector2(-1,1))
	raycast_arrays.resize(8)
	raycast_arrays.fill(false)
	_initialize_enemy(ENEMY_TYPES.PLACEHOLDER)
	rng.set_seed(int(Time.get_unix_time_from_system()))
	return
	
################################################################################	
## Called by the child to set up the individual mushroom types variables      ##
## Checks if the enemy has all the required nodes for pathing.                ##
## Param: type (Required)                                                     ##
## Returns void                                                               ##
################################################################################
func _initialize_enemy(type: ENEMY_TYPES, activity = ENEMY_ACTIVITIES.DEFAULT ,variant = ENEMY_VARIANTS.DEFAULT, patrol = ENEMY_PATROLS.DEFAULT , health = 1, damage = 1, speed = 250, mass = DEFAULT_MASS):
	self.enemy_type        = type
	self.enemy_activity    = activity
	self.enemy_variant     = variant
	self.enemy_damage      = damage
	self.enemy_health      = health
	self.enemy_speed       = speed
	self.enemy_patrol_type = patrol
	self.enemy_mass        = mass
	is_alive = true
	
	if(control_points == null):
		print("Error: enemy.gd | _initialize_enemy() | The enemy doesn't have the control points node")
		print("Object: " + self.name + "!")
		self.enemy_patrol_type = ENEMY_PATROLS.DEFAULT
		return
	# Check the patrol type nodes
	# I'm not going to write code to check if the points are within the navmesh
	# So be sure to triple check that the nodes dont leave the navmesh.
	match enemy_patrol_type:
		# Path requires two nodes, A and B
		ENEMY_PATROLS.PATH:
			if(control_points.get_child_count() != 2):
				print("Error: enemy.gd | _initialize_enemy() | The enemy doesn't have the correct pathing points.")
				print("Has \'" + str(control_points.get_child_count())  + "\' expected 2 for Path Patrol!")
				print("Object: " + self.name + "!")
				# Sets the type to no_ai to prevent errors
				
				return
		# Area requires atleast two points
		ENEMY_PATROLS.AREA:
			if(control_points.get_child_count() < 2):
				print("Error: enemy.gd | _initialize_enemy() | The enemy doesn't have the correct pathing points.")
				print("Has \'" + str(control_points.get_child_count())  + "\' expected less than 2 for Area Patrol!")
				print("Object: " + self.name + "!")
				# Sets the type to no_ai to prevent errors
				self.enemy_patrol_type = ENEMY_PATROLS.DEFAULT
				return
		# Guarding requires only 1 point
		ENEMY_PATROLS.GUARDING:
			if(control_points.get_child_count() != 1):
				print("Error: enemy.gd | _initialize_enemy() | The enemy doesn't have the correct pathing points.")
				print("Has \'" + str(control_points.get_child_count())  + "\' expected 1 for Guarding!")
				print("Object: " + self.name + "!")
				# Sets the type to no_ai to prevent errors
				self.enemy_patrol_type = ENEMY_PATROLS.DEFAULT
				return
			else:
				# Set the point to the guard vector
				var point = control_points.get_child(0) as Node2D
				guard_vector = point.global_position
		# No AI
		ENEMY_PATROLS.DEFAULT:
			pass
	return
	
################################################################################
## This function gets the vector for an enemy that is currently pursuing the  ##
## Player. It takes the players current position and tracks toward it.        ##
## Returns a vector2                                                          ##
################################################################################
func get_attacking_vector(player: Player) -> Vector2:
	var vector = Vector2(0,0)
	nav_agent.get_next_path_position()
	
	nav_agent.target_position = player.global_position
	
	if(nav_agent.distance_to_target() >= 40):
		vector = nav_agent.get_next_path_position() - global_position
		vector = vector.normalized()
		#vector = get_best_vector(vector)
	
	return vector

################################################################################
## This function gets the vector for an enemy that is currently patrolling.   ##
## It gets the patrol type and calculates the route for it to go.             ##
## Returns a vector2                                                          ##
################################################################################
func get_patroling_vector() -> Vector2:
	var vector = Vector2(0,0)
	# Get which patrol type the enemy is currently using
	match enemy_patrol_type:
		# NO AI
		ENEMY_PATROLS.DEFAULT:
			vector = Vector2(0,0)
		# The enemy is moving between two points.
		ENEMY_PATROLS.PATH:
			return await AI_patrol_path()
		# The enemy is patrolling an area
		ENEMY_PATROLS.AREA:
			return await AI_patrol_area()
		# The enemy is guarding a point
		ENEMY_PATROLS.GUARDING:
			return AI_guarding()
		# NOT IMPLEMENTED YET
		ENEMY_PATROLS.SEARCH:
			pass
	
	return vector

func get_best_vector(target_vector: Vector2) -> Vector2:
	
	for index in range(8):
		if(raycast_arrays[index]):
			if(obstacles_scalars.vec_array[wrapi(index - 1,0, 7)].x != -5): 
				obstacles_scalars.vec_array[wrapi(index - 1,0, 7)].x = -2
			obstacles_scalars.vec_array[index].x = -5
			if(obstacles_scalars.vec_array[wrapi(index + 1,0, 7)].x != -5): 
				obstacles_scalars.vec_array[wrapi(index + 1,0, 7)].x = -2
		else:
			if(obstacles_scalars.vec_array[wrapi(index - 1,0, 7)].x != -5): 
				obstacles_scalars.vec_array[wrapi(index - 1,0, 7)].x = 1
			obstacles_scalars.vec_array[index].x = 1
			if(obstacles_scalars.vec_array[wrapi(index + 1,0, 7)].x != -5): 
				obstacles_scalars.vec_array[wrapi(index + 1,0, 7)].x = 1
				

	for index in range(8):
		var dot = target_vector.dot(normalized_dir_vectors.vec_array[index]) * obstacles_scalars.vec_array[index].x * weighted_scalars.vec_array[index].x
		calculated_choice.vec_array[index].x = dot
	
	var vector = normalized_dir_vectors.vec_array[PathVectors.get_max_index(calculated_choice.vec_array)]
	return vector

################################################################################
## AI Behaviour: Patrol Path                                                  ##
## Follows a path created between two points.                                 ##
## Returns a vector2 which is needed to navigate                              ##
################################################################################
func AI_patrol_path() -> Vector2:
	var vector = Vector2(0,0)
	# set the target for the navigation
	var point = control_points.get_child(path_switch) as Node2D 
	nav_agent.target_position = point.global_position
	
	# When the enemy has reached the POI and wasnt already standing there.
	if(nav_agent.distance_to_target() <= POI_DEADZONE && waiting == false):
		waiting = true
		await get_tree().create_timer(WAIT_TIME).timeout
		path_switch = path_switch ^ 1
		waiting = false
		
	# Just stop moving until you need to move again
	elif waiting:
		vector = Vector2(0,0)
		
	# Get the nav path vector
	else:
		vector = nav_agent.get_next_path_position() - global_position
		vector = vector.normalized()
		#vector = get_best_vector(vector)
		
	return vector

################################################################################
## AI Behaviour: Patrol Area                                                  ##
## Follows a path between select points chosen at random.                     ##
## Returns a vector2 which is needed to navigate.                             ##
################################################################################
func AI_patrol_area() -> Vector2:
	var vector = Vector2(0,0)
	
	# set the target for the navigation
	var point = control_points.get_child(area_switch) as Node2D 
	nav_agent.target_position = point.global_position
	
	# When the enemy has reached the POI and didnt already reach it
	if(nav_agent.distance_to_target() <= POI_DEADZONE && not waiting):
		waiting = true
		await get_tree().create_timer(WAIT_TIME).timeout
		var random = rng.randi_range(0, control_points.get_child_count() - 1)
		while(area_switch == random):
			random = rng.randi_range(0, control_points.get_child_count() - 1)
		area_switch = random
		waiting = false
	# Just stop moving until you need to move again
	elif waiting:
		vector = Vector2(0,0)
	# Get the nav path vector
	else:
		vector = nav_agent.get_next_path_position() - global_position
		vector = vector.normalized()
		#vector = get_best_vector(vector)
	
	return vector


################################################################################
## AI Behaviour: Guarding                                                     ##
## Stands still at a point, contains code to return to that point.            ##
## Returns a vector2 which is needed to navigate.                             ##
################################################################################
func AI_guarding() -> Vector2:
	var vector = Vector2(0,0)
	
	if(nav_agent.distance_to_target() <= POI_DEADZONE):
		vector = Vector2(0,0)
	else:
		nav_agent.target_position = guard_vector
		vector = nav_agent.get_next_path_position() - global_position
		vector = vector.normalized()
		#vector = get_best_vector(vector)
		
	return vector
	
################################################################################
## AI Behaviour: Steering                                                     ##
## Makes minor adjustments to the vectors to provide smoother turning.        ##
## Based on GDQuest's steering guide.                                         ##
## Returns a corrected steer vector.                                          ##
################################################################################
func AI_steering(current_velocity: Vector2, current_position: Vector2, target_position: Vector2) -> Vector2:
	var desired_velocity = (target_position - current_position).normalized() * enemy_speed
	var steering = (desired_velocity - velocity) / enemy_mass
	return velocity + steering
	
################################################################################	
## Called when the enemy is taking damage,                                    ##
## Returns a bool indicating if the enemy died.                               ##
################################################################################
func take_damage(damage_amount : float) -> bool:
	# Visual Damage Indication
	self.enemy_health -= damage_amount
	animated_sprite_2d.material = Globals.DAMAGE_FLASH
	await get_tree().create_timer(0.15).timeout
	animated_sprite_2d.material = null
	if (self.enemy_health <= 0):
		has_died()
		return true
	return false


################################################################################
## Called when an attack from the sub_class lands on a player and needs       ## 
## to assign damage.                                                          ##
## Returns void                                                               ##
################################################################################
func hit_player(player : Player):
	player.receive_damage(self.enemy_damage)
	
################################################################################
## Called when the enemy is no longer supposed to live                        ##
## Returns void                                                               ##
################################################################################
func has_died():
	self.is_alive = false
	#TODO implement
	pass

################################################################################
##                       Callbacks and other Callables                        ##
################################################################################
