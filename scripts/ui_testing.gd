extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var test = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(test):
		test = false
		await get_tree().create_timer(2).timeout
		show_diag_one()
		

func show_diag_one():
	CanvasDialog.show_dialog("This is a test to see if the thingy types it out correctly", show_diag_two, 3, 600)
	
func show_diag_two():
	CanvasDialog.show_dialog(Dialogs.scenename_1_1, show_diag_three, 2)
	
func show_diag_three():
	CanvasDialog.show_dialog(Dialogs.fact, cutscene_finished, 3)
	
func cutscene_finished():
	print("Finished showing story test.")
