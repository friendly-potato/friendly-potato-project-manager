extends BaseModdedFileDialog

const PLUGIN_CFG: String = "plugin.cfg"

var current_item: TreeItem

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	tree.select_mode = Tree.SELECT_SINGLE
	
	popup_centered_ratio()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_file_selected() -> void:
	var ti := tree.get_selected()
	current_item = ti

	var dir := Directory.new()
	if not dir.file_exists("%s/%s/%s" %
			[
				current_dir,
				current_item.get_text(tree.get_selected_column()),
				PLUGIN_CFG
			]):
		button.disabled = true
		return

	button.disabled = false

func _on_modded_button() -> void:
	emit_signal("finished_selecting", "%s/%s" %
		[
			current_dir,
			current_item.get_text(tree.get_selected_column())
		])
	queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
