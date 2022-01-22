extends PanelContainer

onready var label: Label = $HBoxContainer/Label
onready var check: CheckBox = $HBoxContainer/CheckBox

var text: String = ""
var initial_pressed_value := false
var button_group: ButtonGroup

var mouseover_label: Label

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	if AppManager.cm.config().show_full_file_paths:
		label.text = text
	else:
		label.text = text.get_file()
		hint_tooltip = text
	check.pressed = initial_pressed_value
	if button_group != null:
		check.group = button_group

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func checked() -> bool:
	return check.pressed
