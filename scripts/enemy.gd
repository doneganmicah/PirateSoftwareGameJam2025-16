################################################################################
## This is the Enemy base class. It contains properties such as Health,       ##
## Ailments, and AI Goals.                                                    ##
## This class will be inherited by the actual enemy type class.               ##
################################################################################  
class_name Enemy
extends Node2D

################################################################################
##                             Constants & Enums                              ##
################################################################################
## Enumerators
# TODO: THESE WILL NEED TO BE CHANGED TO MATCH WHATEVER WE NEED THEM TOO
# Enemy Type is the child_class reference.
enum ENEMY_TYPES       {MELEE, RANGE, PLACEHOLDER} 
# Enemy Variant is for different skins.
enum ENEMY_VARIANTS    {DEFAULT, MUSHROOM_ONE, MUSHROOM_REDCAP, MUSHROOM_DOGE} 
# This is what the enemy's current objective is. (Default is NO_AI)
enum ENEMY_ACTIVITIES  {DEFAULT, PATROLING, ALERTED, ATACKING}
# This is what the enemy's patrol looks like. (Default is similar to NO_AI)
enum ENEMY_PATROLS     {DEFAULT, SET_PATH, AREA, GUARDING, SEARCH} 

## Constants
const MAX_HEALTH = 3 # The maximum amount of health for an enemy.
const MAX_DAMAGE = 1 # The maximum amount of damage an enemy can do.

################################################################################
##                                 Properties                                 ##
################################################################################
## Child Nodes
# Instance of the RigidBody
@onready var rigid_body_2d: RigidBody2D = $RigidBody2D:
	get: return rigid_body_2d
# Instance of Area2D where melee attack can hit
@onready var melee_attack_effective_range: Area2D = $MeleeAttackEffectiveRange:
	get: return melee_attack_effective_range
# Instance of the sprite Renderer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D:
	get: return animated_sprite_2d
		
## Members
# This is the amount of health the enemy has, will be set by the child class.
var enemy_health : int:
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
# If the enemy has been sickened by spoors, causing coughing and slower movement.
var is_spoor_sick: bool:
	get: return is_spoor_sick
	set(value): is_spoor_sick = value
# This has nothing to do with his feelings of being alive, this particular guy didnt invest in the houseing market during 2008 not because of his hideous incompetence but because he is a mushroom and it is a well known fact that mushrooms can not make dealings regarding realestate, due to this fact his self of living is critically at a low point.
# If the enemy has died or not.
var is_alive : bool:
	get: return is_alive
	set(value): is_alive = value

################################################################################
##                                 Functions                                  ##
################################################################################

################################################################################
## Fill out some variables to prevent uninitialized errors                    ##
################################################################################
func _init() -> void:
	_initialize_enemy(ENEMY_TYPES.PLACEHOLDER)
	return
	
################################################################################	
## Called by the child to set up the individual mushroom types variables      ##
## Param: type (Required)                                                     ##
## Returns void                                                               ##
################################################################################
func _initialize_enemy(type: ENEMY_TYPES, activity = ENEMY_ACTIVITIES.DEFAULT ,variant = ENEMY_VARIANTS.DEFAULT, health = 1, damage = 1):
	self.enemy_type     = type
	self.enemy_activity = activity
	self.enemy_variant  = variant
	self.enemy_damage   = damage
	self.enemy_health   = health
	return
	
################################################################################	
## Called when the enemy is taking damage,                                    ##
## Returns a bool indicating if the enemy died.                               ##
################################################################################
func take_damage(damage_amount : int) -> bool:
	# Visual Damage Indication
	self.enemy_health -= damage_amount
	if (self.enemy_damage <= 0):
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
	
