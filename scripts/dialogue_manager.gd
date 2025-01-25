################################################################################
## This class is used to manage the dialog system. 
## The rules 
################################################################################
extends CanvasLayer
class_name DialogManager

################################################################################
##                              Constants & Enums                             ##
################################################################################
## Enumerators

## Constants
# The amount of pixels per line
const PIXELS_LINE = 25

################################################################################
##                                 Properties                                 ##
################################################################################
## Child Nodes
# Instance of the color rect to change the shape
@onready var color_rect: ColorRect = $CenterContainer/ColorRect
# Instance of the margin container to change the shape
@onready var margin_container: MarginContainer = $CenterContainer/ColorRect/MarginContainer
# Instance of the text box to display the dialog.
@onready var lbl_dialog: RichTextLabel = $CenterContainer/ColorRect/MarginContainer/RichTextLabel
# Instance of the viewport sized container used to get mouse input events.
@onready var signal_handle: CenterContainer = $signalHandle


## Variables
# If the dialog box is ready to go and displaying
var displaying : bool
# If the dialog is currently being drawn
var drawing : bool
# If the dialog is currently being typed
var typing : bool
# Goal dialog that we want to type out
var diag_reference : String
# The dialog typed so far
var diag_current : String
# The distance typed so far.
var diag_index : int
# Waiting for skip or the timeout to continue on with the dialog
var waiting_for_skip : bool
# The callback that is generated when the dialog box is closed.
var diag_end_callable : Callable

var test = true
################################################################################
##                                 Functions                                  ##
################################################################################

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	drawing = false
	typing = false
	displaying = false
	diag_index = 0
	waiting_for_skip = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(not displaying): return
	if(typing and not drawing):
		drawing = true
		# Check if we reached the end of the current dialog while typing.
		if (diag_reference.length() == diag_current.length() or diag_index + 1 >= diag_reference.length()):
			typing  = false
			drawing = false
			return
		# The time to wait between characters
		await get_tree().create_timer(0.01).timeout
		# Double check if we are still typing since
		# the await will delay the thread of process a user may input a skip diag that then might flicker the full and finished dialog for a fraction. might not happen but this extra check just insures sanity between threads.
		if(typing): 
			# add the next character to the screen
			diag_current += diag_reference[diag_index]
			diag_index += 1
			lbl_dialog.text = diag_current
		# Draw to the screen
		drawing = false
	# We are done typing so just set the diag box text to the goal text.
	# User input skips straight to this
	else:
		lbl_dialog.text = diag_reference

################################################################################
## Show the dialog box to the player.                                         ##
## Takes in a string reference of the text to be displayed.                   ##
## The funciton callback for whent he dialog has completed it's existance.    ##
## The amount of lines for the height of the diag box.                        ##
## The length in pixels for the width of the diag box.                        ##
## Returns void                                                               ##
################################################################################
func show_dialog(diag_ref, diag_end_callback : Callable, lines = 3, length = 600):
	diag_index = 0
	lbl_dialog.text = ""
	self.diag_reference = diag_ref
	diag_end_callable = diag_end_callback
	color_rect.custom_minimum_size = Vector2(length, lines * PIXELS_LINE)
	margin_container.size = Vector2(length, lines * PIXELS_LINE)
	self.visible = true
	signal_handle.connect("gui_input", _get_input_event)
	# delay between box showing up and typing begins
	await get_tree().create_timer(0.25).timeout
	displaying = true
	typing = true

################################################################################
## Close the dialog box.
## 
################################################################################
func close_dialog() -> void:
	self.visible = false
	displaying = false
	diag_reference = ""
	diag_current = ""
	signal_handle.disconnect("gui_input", _get_input_event)
	diag_end_callable.call()
	typing = true
	

func _get_input_event(event: InputEvent) -> void:
	if(event.is_action_pressed("skip_dialog")):
		if(typing): typing = false
		else: close_dialog()
