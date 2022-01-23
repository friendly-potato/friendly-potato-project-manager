class_name ProjectItem
extends BaseHoverElement

var changed_color: Color

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	changed_color = before_color
	
	label = $HBoxContainer/Label
	_set_label_text(label, path)

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
