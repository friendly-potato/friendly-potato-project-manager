extends BaseModdedFileDialog

var search_path: String

var selected_items: Array = []

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	tree.select_mode = Tree.SELECT_MULTI
	tree.allow_reselect = true
	
	popup_centered_ratio()
	
	yield(get_tree(), "idle_frame")
	
	# The first item starts out selected so force an unselect
	tree.get_selected().deselect(tree.get_selected_column())

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_files_selected(ti: TreeItem, column: int, selected: bool) -> void:
	"""
	Hack for bypassing Godot's builtin FileDialog selection limits
	
	AKA you cannot multiselect files + directories, only files
	"""
	var text: String = ti.get_text(column)
	AppManager.logger.info(text)
	match selected:
		true:
			if selected_items.has(text):
				ti.deselect(column)
				_remove_item(text)
			else:
				_add_item(text)
		false:
			_remove_item(text)

func _on_deselected(pos: Vector2) -> void:
	var ti: TreeItem = tree.get_item_at_position(pos)
	var col: int = tree.get_column_at_position(pos)
	
	selected_items.erase(ti.get_text(col))
	ti.deselect(col)

func _on_modded_button() -> void:
	emit_signal("finished_selecting", selected_items)
	queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

func _set_current_dir() -> void:
	current_dir = search_path

func _add_item(text: String) -> void:
	selected_items.append(text)
	button.disabled = false

func _remove_item(text: String) -> void:
	selected_items.erase(text)
	if selected_items.size() == 0:
		button.disabled = true

###############################################################################
# Public functions                                                            #
###############################################################################
