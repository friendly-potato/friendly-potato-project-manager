extends FileDialog

signal finished_selecting(selected_items)

var button: Button
var tree: Tree

var selected_items: Array = []

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	current_dir = AppManager.cm.config().default_search_path
	
	var popup_vbox: VBoxContainer = get_vbox()
	
	# Modify accept buttons
	var popup_accept_buttons: HBoxContainer = popup_vbox.get_parent().get_child(2)
	popup_accept_buttons.get_child(1).hide()
	button = Button.new()
	button.text = "Select"
	button.disabled = true
	button.connect("pressed", self, "_on_modded_button")
	popup_accept_buttons.add_child_below_node(popup_accept_buttons.get_child(0), button)
	
	# Modify tree view (files/dir display)
	tree = popup_vbox.get_child(2).get_child(0)
	if not tree is Tree:
		AppManager.logger.error("Unable to modify FileDialog:VBox:Tree. " +
				"Maybe something changed in the builtin FileDialog implementation")
	else:
		tree.select_mode = Tree.SELECT_MULTI
		tree.allow_reselect = true
		tree.allow_rmb_select = true
		tree.connect("multi_selected", self, "_on_file_selected")
		tree.connect("item_rmb_selected", self, "_on_deselected")
	
	popup_centered_ratio()
	
	yield(get_tree(), "idle_frame")
	
	# The first item starts out selected so force an unselect
	tree.get_selected().deselect(tree.get_selected_column())

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_file_selected(ti: TreeItem, column: int, selected: bool) -> void:
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

func _add_item(text: String) -> void:
	selected_items.append(text)
	button.disabled = false

func _remove_item(text: String) -> void:
	selected_items.erase(text)
	if selected_items.size() == 0:
		button.disabled == true

###############################################################################
# Public functions                                                            #
###############################################################################
