class_name ProjectItem
extends BaseHoverElement

signal clicked()

onready var label: Label = $HBoxContainer/Label

var changed_color: Color

var path

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	changed_color = before_color

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked")

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
