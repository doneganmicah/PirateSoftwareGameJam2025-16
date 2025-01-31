################################################################################
## This is the master game controller than manages the scenes and ui.         ##
## Based off of StayAtHomeDev's implemintation of scene management.           ##
################################################################################ 
class_name GameController extends Node

@export var scene_2d : Node2D
@export var gui : Control

var current_2d_scene : Node2D
var current_gui_scene : Control

func _ready() -> void:
	Globals.game_controller = self

func change_gui_scene(new_scene: String, delete: bool = true, keep_running = false) -> void:
	if(current_gui_scene != null):
		if delete:
			current_gui_scene.queue_free() # Remove the scene from memory
		elif keep_running: # really only used with pause screen probably
			current_gui_scene.visible = false # Keeps in memory and running
		else:
			gui.remove_child(current_gui_scene) # Keeps in memory, does not run
	var scene = load(new_scene) as PackedScene  # Load the new scene into memory
	var new = scene.instantiate()
	gui.add_child(new) # Add it to the running tree
	current_gui_scene = new 
	
func change_2d_scene(new_scene: String, delete: bool = true, keep_running = false) -> void:
	if(current_2d_scene != null):
		if delete:
			current_2d_scene.queue_free() # Remove the scene from memory
		elif keep_running:
			current_2d_scene.visible = false # Keeps in memory and running
		else:
			scene_2d.remove_child(current_2d_scene) # Keeps in memory, does not run
	var scene = load(new_scene) as PackedScene  # Load the new scene into memory
	var new = scene.instantiate()
	scene_2d.add_child(new) # Add it to the running tree
	current_2d_scene = new 
