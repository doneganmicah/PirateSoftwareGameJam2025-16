################################################################################
## This program is to handle when a player enters the range of the calming.   ##
## stump. The timer class will call a timeout signal that lowers the range    ##
## of the players spore AoE.                                                  ##
################################################################################
extends Node2D

################################################################################
##                             Constants & Enums                              ##
################################################################################

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_effecting = false
	timer.one_shot = false
	#enable to the spore particles


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_player_enter(body : Node2D) -> void:
	if(body.is_in_group("player")):
		# A cheao way to get the instance of the player
		player = body as Player
		print("Enter log range")
		is_effecting = true
		timer.start(0.5)

func _on_player_leave(body : Node2D) -> void:
	if(body.is_in_group("player")):
		print("left log range")
		is_effecting = false
		timer.stop()

func _on_timer_timeout() -> void:
	if(player != null):
		# Call player lower AoE
		pass
		
