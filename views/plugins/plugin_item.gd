class_name PluginItem
extends BaseHoverElement

onready var buttons: HBoxContainer = $HBoxContainer/HBoxContainer
var store_locally_button: StoreLocallyButton

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	label = $HBoxContainer/Label
	_set_label_text(label, path)
	
	buttons.add_child(store_locally_button)

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
