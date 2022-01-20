extends WindowDialog

var parent: BaseView

onready var project_name: LineEdit = $VBoxContainer/ScrollContainer/VBoxContainer/ProjectLineEdit
onready var project_path: LineEdit = $VBoxContainer/ScrollContainer/VBoxContainer/ProjectPathContainer/ProjectPathLineEdit

onready var create_edit: Button = $VBoxContainer/HBoxContainer/CreateEdit
onready var cancel: Button = $VBoxContainer/HBoxContainer/Cancel

onready var templates: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/TemplatesContainer/Templates
onready var plugins: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/PluginsContainer/Plugins
var plugin_buttons: Array = []

var button_group := ButtonGroup.new()
var template_group := ButtonGroup.new()

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	connect("popup_hide", AppManager, "destroy_node", [self])
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/GL3/CheckBox.group = button_group
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/GL2/CheckBox.group = button_group
	
	$VBoxContainer/ScrollContainer/VBoxContainer/ProjectPathContainer/Button.connect("pressed", self, "_on_browse")
	
	var popup_item: PackedScene = load("res://views/projects/new-project-popup/popup_item.tscn")
	
	# Add default (empty) project template first
	var default_template = popup_item.instance()
	default_template.text = "Default"
	default_template.initial_pressed_value = true
	default_template.button_group = template_group
	templates.add_child(default_template)
	
	_populate_templates_plugins()
	
	create_edit.connect("pressed", self, "_on_create_edit")
	cancel.connect("pressed", AppManager, "destroy_node", [self])
	
	popup_centered_ratio()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_browse() -> void:
	var popup: FileDialog = parent.create_dir_selector()
	popup.connect("dir_selected", self, "_on_dir_selected")
	
	add_child(popup)
	popup.popup_centered_ratio()

func _on_create_edit() -> void:
	var template: String = _get_parent_for_popup_button(template_group.get_pressed_button()).text
	
	var selected_plugins: Array = []
	for p in plugins.get_children():
		if p.checked():
			selected_plugins.append(p.text)
	
	AppManager.logger.info(str(selected_plugins))
	AppManager.logger.info(template)

func _on_dir_selected(dir: String) -> void:
	project_path.text = dir

###############################################################################
# Private functions                                                           #
###############################################################################

func _get_parent_for_popup_button(i: BaseButton) -> Node:
	"""
	Get the parent for a given button from a ButtonGroup
	"""
	return i.get_parent().get_parent()

func _populate_templates_plugins() -> void:
	var is_first := true
	for c in templates.get_children():
		if is_first:
			continue
		c.free()
	
	for c in plugins.get_children():
		c.free()
	
	var popup_item: PackedScene = load("res://views/projects/new-project-popup/popup_item.tscn")
	
	for t in AppManager.cm.current_config.templates:
		var item = popup_item.instance()
		item.text = t
		item.button_group = template_group
		templates.add_child(item)
	
	for p in AppManager.cm.current_config.plugins:
		var item = popup_item.instance()
		item.text = p
		plugins.add_child(item)

###############################################################################
# Public functions                                                            #
###############################################################################
