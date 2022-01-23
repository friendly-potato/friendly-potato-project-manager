class_name BaseModdedFileDialog
extends FileDialog

# warning-ignore:unused_signal
signal finished_selecting(selected_item)

var button: Button
var tree: Tree

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	var popup_vbox: VBoxContainer = get_vbox()
	
	# Modify accept buttons
	var popup_accept_buttons: HBoxContainer = popup_vbox.get_parent().get_child(2)
	popup_accept_buttons.get_child(1).hide()
	button = Button.new()
	button.text = "Select"
	button.disabled = true
# warning-ignore:return_value_discarded
	button.connect("pressed", self, "_on_modded_button")
	popup_accept_buttons.add_child_below_node(popup_accept_buttons.get_child(0), button)

	# Modify tree view (files/dir display)
	tree = get_vbox().get_child(2).get_child(0)
	if not tree is Tree:
		AppManager.logger.error("Unable to modify FileDialog:VBox:Tree. " +
				"Maybe something changed in the builtin FileDialog implementation")
	else:
		tree.allow_rmb_select = true
# warning-ignore:return_value_discarded
		tree.connect("item_selected", self, "_on_file_selected")
# warning-ignore:return_value_discarded
		tree.connect("multi_selected", self, "_on_files_selected")
# warning-ignore:return_value_discarded
		tree.connect("item_rmb_selected", self, "_on_deselected")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_file_selected() -> void:
	pass

func _on_files_selected(_ti: TreeItem, _column: int, _selected: bool) -> void:
	pass

func _on_modded_button() -> void:
	AppManager.logger.error("Not yet implemented")

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
