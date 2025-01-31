extends Node
class_name Scenes

const main_menu : String = "res://scenes/main_menu.tscn"
const level_one : String = "res://scenes/levels/Level_One.tscn"
const level_two : String = "res://scenes/levels/Level_Two.tscn"
const level_three : String = "res://scenes/levels/Level_Three.tscn"
const test_level : String = "res://scenes/levels/tests/testing_level.tscn"
const opening_cutscene : String = "res://scenes/ui_elements/opening_cutscene.tscn"

func _ready() -> void:
	Globals.scenes = self
