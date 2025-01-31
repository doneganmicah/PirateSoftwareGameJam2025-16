extends Node
class_name Scenes

const main_menu : String = "res://scenes/main_menu.tscn"
const level_one : String = "res://scenes/levels/Level_One.tscn"
const test_level : String = "res://scenes/levels/tests/testing_level.tscn"

func _ready() -> void:
	Globals.scenes = self
