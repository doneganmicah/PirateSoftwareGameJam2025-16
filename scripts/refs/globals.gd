extends Node

var game_controller : GameController
var scenes = Scenes

# Player variables should be written here between level changes and not accessed during
# normal game runtime to prevent race conditions.
var player_first_instantiated = false
var player_health = 0
var player_ring_size = 0
var player_killed_enemies = 0
var player_good_bad_ratio = 60
var palyer_completed_levels = 0
