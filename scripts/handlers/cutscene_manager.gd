extends Control

var opening_text_rect : TextureRect
var ending_text_rect : TextureRect
@onready var dialog: DialogManager = $CanvasDialog
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta: float) -> void:
	if(Input.is_action_just_pressed("skip_cutscene")):
		if(Globals.is_end):
			Globals.game_controller.get_tree().reload_current_scene()
		dialog.diag_end_callable = end_opening
		dialog.close_dialog()
	
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (not Globals.is_end):
		animation_player.play("start")
		_start_cutscene()
	else:
		_start_endscene()

func _start_cutscene():
	dialog.show_dialog(Dialogs.opening_cutscene_1_1, show_dialog_2)
	
func show_dialog_2():
	animation_player.play("cutscene0-1")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_1_2, show_dialog_3)
	
func show_dialog_3():
	animation_player.play("cutscene1-2")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_2_1, show_dialog_4)

func show_dialog_4():
	dialog.show_dialog(Dialogs.opening_cutscene_2_2, show_dialog_5)
	
func show_dialog_5():
	animation_player.play("cutscene2-3")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_3_1, show_dialog_6)

func show_dialog_6():
	dialog.show_dialog(Dialogs.opening_cutscene_3_2, show_dialog_7, 5)
	
func show_dialog_7():
	animation_player.play("cutscene3-4")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_4_1, show_dialog_8)
	
func show_dialog_8():
	dialog.show_dialog(Dialogs.opening_cutscene_4_2, show_dialog_9, 4)
	
func show_dialog_9():
	animation_player.play("cutscene4-5")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_5_1, show_dialog_10)

func show_dialog_10():
	dialog.show_dialog(Dialogs.opening_cutscene_5_2, show_dialog_11, 4)
	
func show_dialog_11():
	animation_player.play("cutscene5-6")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_6_1, show_dialog_12)
	
func show_dialog_12():
	dialog.show_dialog(Dialogs.opening_cutscene_6_2, show_dialog_13)

func show_dialog_13():
	dialog.show_dialog(Dialogs.opening_cutscene_6_3, show_dialog_14)
	
func show_dialog_14():
	animation_player.play("cutscene6-blank")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_x_1, show_dialog_15)
	
func show_dialog_15():
	dialog.show_dialog(Dialogs.opening_cutscene_x_2, show_dialog_16)

func show_dialog_16():
	animation_player.play("cutsceneblank-7")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_7_1, show_dialog_17)

func show_dialog_17():
	dialog.show_dialog(Dialogs.opening_cutscene_7_2, show_dialog_18)
	
func show_dialog_18():
	dialog.show_dialog(Dialogs.opening_cutscene_7_3, show_dialog_19)
	
func show_dialog_19():
	animation_player.play("cutscene7-8")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_8_1, show_dialog_20)
	
func show_dialog_20():
	dialog.show_dialog(Dialogs.opening_cutscene_8_2, show_dialog_21)
	
func show_dialog_21():
	dialog.show_dialog(Dialogs.opening_cutscene_8_3, show_dialog_22)
	
func show_dialog_22():
	animation_player.play("cutscene8-blank")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_x_3, show_dialog_23)
	
func show_dialog_23():
	dialog.show_dialog(Dialogs.opening_cutscene_x_4, end_opening)
	
func end_opening():
	Globals.game_controller.change_2d_scene(Globals.scenes.level_one)
	
func _start_endscene():
	AudioManager.play_music("Finale")
	
	if(Globals.really_evil):
		animation_player.play("start_end_bad")
		await animation_player.animation_finished
		dialog.show_dialog(Dialogs.opening_cutscene_9_1, bad_dialog_1)
	else:
		animation_player.play("start_end_good")
		dialog.show_dialog(Dialogs.opening_cutscene_10_1, good_dialog_1)
		await animation_player.animation_finished
	
func bad_dialog_1():
	animation_player.play("end_end_bad")
	await animation_player.animation_finished
	await dialog.show_dialog(Dialogs.opening_cutscene_9_2, end_the_game)
	
func good_dialog_1():
	animation_player.play("mid_end_good")
	await animation_player.animation_finished
	dialog.show_dialog(Dialogs.opening_cutscene_10_2, good_dialog_2)

func good_dialog_2():
	animation_player.play("end_end_bad")
	await animation_player.animation_finished
	await dialog.show_dialog(Dialogs.opening_cutscene_10_3, end_the_game)
	
func end_the_game():
	await AudioManager.finished
	Globals.game_controller.get_tree().reload_current_scene()
