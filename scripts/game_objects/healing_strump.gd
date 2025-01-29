################################################################################
## This program is to handle when a player enters the range of the healing    ##
## stump. Heals the player immediatly when they enter the Area of Effect.     ##
################################################################################
extends Node2D

################################################################################
##                             Constants & Enums                              ##
################################################################################

################################################################################
##                                 Properties                                 ##
################################################################################
## Node Instances
# We need instance of player from the beginning of the level to determine if they require the stump or not
@export var player : Player

## Variables
# The player is full health.
var is_fully_healed = false
# If the health has been used from this log yet.
var is_used = false

################################################################################
##                                 Functions                                  ##
################################################################################

################################################################################
## Called when the node enters the scene tree for the first time.             ##
################################################################################
func _process(delta: float) -> void:
	if(player.health >= player.MAX_HEALTH):
		is_fully_healed = true
	else:
		is_fully_healed = false
	
	if(not is_used):
		# emit particles!
		pass
		
	
################################################################################
## Called when an object enters the area2d attached to the log. If it is a    ##
## player it will add health to the player if it can.                         ##
## Receives the node2D that entered.                                          ##
## Returns void                                                               ##
################################################################################
func _on_player_enter(body : Node2D) -> void:
	if(is_fully_healed or is_used): return
	if(body.is_in_group("player")):
		print("Healing Player")
		player.health += 1
		player.update_health_visual()
		is_used = true
		# Emit Extra particles!
		

################################################################################
## Called when an object leaves the area2d attached to the log. If it is a    ##
## player it will end the timer that calms the players spore ring.            ##
## Receives the node2d that left the area.                                    ##
## Returns void                                                               ##
################################################################################
func _on_player_leave(body : Node2D) -> void:
	if(body.is_in_group("player")):
		print("left log range")
