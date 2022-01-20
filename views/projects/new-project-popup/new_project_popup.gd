extends WindowDialog

onready var project_name: LineEdit = $VBoxContainer/ScrollContainer/VBoxContainer/ProjectLineEdit
onready var project_path: LineEdit = $VBoxContainer/ScrollContainer/VBoxContainer/ProjectPathContainer/ProjectPathLineEdit

onready var create_edit: Button = $VBoxContainer/HBoxContainer/CreateEdit
onready var cancel: Button = $VBoxContainer/HBoxContainer/Cancel

onready var templates: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/TemplatesContainer/Templates
onready var plugins: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/PluginsContainer/Plugins

var button_group := ButtonGroup.new()
var template_group := ButtonGroup.new()

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	connect("popup_hide", self, "destroy")
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/GL3/CheckBox.group = button_group
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/GL2/CheckBox.group = button_group
	
	var popup_item: PackedScene = load("res://views/projects/new-project-popup/new_project_popup.tscn")
	
	for t in AppManager.cm.current_config.templates:
		var item = popup_item.instance()
		add_child(item)
		item.check.group = template_group
	
	for p in AppManager.cm.current_config.templates:
		pass
	
	create_edit.connect("pressed", self, "_on_create_edit")
	cancel.connect("pressed", self, "destroy")
	
	popup_centered_ratio()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_create_edit() -> void:
	var pressed_button: BaseButton = template_group.get_pressed_button()
	if pressed_button != null:
		var p = _get_parent_for_popup_button(pressed_button)
	
	print(pressed_button)

###############################################################################
# Private functions                                                           #
###############################################################################

func _get_parent_for_popup_button(i: BaseButton) -> Node:
	"""
	Get the parent for a given button from a ButtonGroup
	"""
	return i.get_parent().get_parent()

###############################################################################
# Public functions                                                            #
###############################################################################

func destroy() -> void:
	queue_free()
