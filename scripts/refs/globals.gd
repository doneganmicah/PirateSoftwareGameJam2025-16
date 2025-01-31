extends Node

var game_controller : GameController
var scenes = Scenes

# Player variables should be written here between level changes and not accessed during
# normal game runtime to prevent race conditions.
var player_first_instantiated = false
var player_health = 3
var player_ring_size = 8
var player_killed_enemies = 0
var player_hurt_enemies   = 0
var player_completed_levels = 0
var slightly_evil : bool = false
var really_evil : bool = false

# instance of material for damage flash
@onready var DAMAGE_FLASH : Material = preload("res://assets/shaders/damage_flash.tres")
