extends BaseModdedFileDialog

const PLUGIN_CFG: String = "plugin.cfg"

var current_item: String

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
	current_item = ti.get_text(tree.get_selected_column())

	var dir := Directory.new()
	if not dir.file_exists("%s/%s/%s" %
			[
				current_dir,
				current_item,
				PLUGIN_CFG
			]):
		button.disabled = true
		return

	button.disabled = false

func _on_modded_button() -> void:
	emit_signal("finished_selecting", "%s/%s" %
		[
			current_dir,
			# If triggered from inside the selected directory, the directory name will be doubled
			# Check for the doubling
			current_item if current_item != current_dir.get_file() else ""
		])
	queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
