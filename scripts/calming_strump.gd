################################################################################
## This program is to handle when a player enters the range of the calming.   ##
## stump. The timer class will call a timeout signal that lowers the range    ##
## of the players spore AoE.                                                  ##
################################################################################
extends Node2D

################################################################################
##                             Constants & Enums                              ##
################################################################################
const TIMER_WAIT_TIME = 0.5 # The amount of time between the timer timeouts.

################################################################################
##                                 Properties                                 ##
################################################################################
## Child Nodes
# Instance of the timer that is called when the player enteres the range of the stump
@onready var timer: Timer = $Timer

## Variables
# The player has been calmed.
var is_effecting : bool
# Instance of the player.
var player : Player

################################################################################
##                                 Functions                                  ##
################################################################################

################################################################################
## Called when the node enters the scene tree for the first time.             ##
################################################################################
func _ready() -> void:
	is_effecting = false
	timer.one_shot = false
	timer.wait_time = TIMER_WAIT_TIME
	#enable to the spore particles

################################################################################
## Called when an object enters the area2d attached to the log. If it is a    ##
## player it will start the timer that calms the players spore ring.          ##
## Receives the node2D that entered.                                          ##
## Returns void                                                               ##
################################################################################
func _on_player_enter(body : Node2D) -> void:
	if(body.is_in_group("player")):
		# A cheap way to get the instance of the player
		player = body as Player
		print("Enter log range")
		is_effecting = true
		timer.start(TIMER_WAIT_TIME)

################################################################################
## Called when an object leaves the area2d attached to the log. If it is a    ##
## player it will end the timer that calms the players spore ring.            ##
## Receives the node2d that left the area.                                    ##
## Returns void                                                               ##
################################################################################
func _on_player_leave(body : Node2D) -> void:
	if(body.is_in_group("player")):
		print("left log range")
		is_effecting = false
		timer.stop()

################################################################################
## Called by the timer's timeout when amount of time passed. When it is called##
## the player will recieve calming.                                           ##
## Returns void                                                               ##
################################################################################
func _on_timer_timeout() -> void:
	if(player != null):
		print("Be calm!")
		# Call player lower AoE
		pass
