class_name LoadableCopyView
extends BaseView

onready var items: VBoxContainer = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
# warning-ignore:return_value_discarded
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Add.connect("pressed", self, "_on_add")
# warning-ignore:return_value_discarded
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Remove.connect("pressed", self, "_on_remove")
	
	_copy_buttons()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_item_clicked(item: BaseHoverElement) -> void:
	if current_element != null:
		current_element.before_color = current_element.after_color
		current_element.unhover()
	current_element = item
	current_element.before_color = current_element.after_color

func _on_add() -> void:
	var popup := create_dir_selector()
# warning-ignore:return_value_discarded
	popup.connect("dir_selected", self, "_on_dir_selected")
	popup.current_dir = AppManager.cm.config().default_search_path
	
	add_child(popup)
	popup.popup_centered_ratio()

func _on_dir_selected(dir: String) -> void:
	dir = FileSystem.strip_drive(dir)
	
	items.add_child(_add_item(dir))
	_add_to_config(dir)

func _on_remove() -> void:
	# Must be implemented in children since order matters
	AppManager.logger.error("Not yet implemented")

###############################################################################
# Private functions                                                           #
###############################################################################

func _add_item(_path: String) -> Control:
	AppManager.logger.error("Not yet implemented, using intentionally broken implementation")
	return Control.new()

func _add_to_config(_path: String) -> void:
	AppManager.logger.error("Not yet implemented")

###############################################################################
# Public functions                                                            #
###############################################################################
