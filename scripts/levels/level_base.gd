################################################################################
## This is the base level script which gives appropriate functions for        ##
## Controlling and Navigating level states.                                   ##
################################################################################
extends Node2D
class_name Level

################################################################################
##                             Constants & Enums                              ##
################################################################################
## Enumerators

## Constants

################################################################################
##                                 Properties                                 ##
################################################################################
## Child nodes

## Inspector Derived
@export_category("Player Nodes")
# The node2D so that its transform can be used to quickly reposition the player during reset
@export var player_starting_node : Node2D
# The area where the when the player enters the level is completed.
@export var player_ending_node : Area2D
# Heck why not just export the player here at this point ¯\_(ツ)_/¯
@export var player : Player

## Variables


################################################################################
##                                 Functions                                  ##
################################################################################

func _init() -> void:
	pass
func reset_level():
	pass
	
func end_level(goto_scene : String):
	print("Finished Level")
	Globals.player_ring_size = player.ringSize
	Globals.player_health = player.health
	await get_tree().create_timer(1).timeout
	if(Globals.game_controller != null):
		Globals.game_controller.change_2d_scene(goto_scene)
	else:
		print("Level over but does not have game_controller to proceed")
	
func pause_level():
	pass
	
func unpause_level():
	pass
