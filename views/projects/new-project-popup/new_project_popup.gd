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
	"""
	Creates the project in the following order
	  1. project.godot
	  2. templates (if applicable)
	  3. plugins (if applicable)
	
	Uses platform-specific copy commands since Godot's builtin copy only
	works for files
	"""
	# Gather information
	var template: String = _get_parent_for_popup_button(template_group.get_pressed_button()).text
	
	var selected_plugins: Array = []
	for p in plugins.get_children():
		if p.checked():
			selected_plugins.append(p.text)
	
	AppManager.logger.info(str(selected_plugins))
	AppManager.logger.info(template)
	
	# TODO currently the folder must exist beforehand
	var dir := Directory.new()
	if not dir.dir_exists(project_path.text):
		AppManager.logger.error("Path does not exist: %s\nDeclining to implicitly create new directory" % project_path.text)
		return
	
	# Execute
	# Execution order:
	#   1. project.godot
	#   2. templates (if applicable)
	#   3. plugins (if applicable)
	var os: String = OS.get_name()
	match os:
		"Windows":
			# This is so gross
			OS.execute("type", ["nul", ">", "%s/project.godot" % project_path.text])
		"X11", "OSX":
			OS.execute("touch", ["%s/project.godot" % project_path.text])
	
	if template != "Default":
		var t_dir := Directory.new()
		if t_dir.open(template) != OK:
			AppManager.logger.error("Unable to open template: %s" % template)
			return

		t_dir.list_dir_begin(true, false)

		var file_name: String = dir.get_next()
		while file_name != "":
			match os:
				"Windows":
					_rec_copy_windows(file_name, project_path.text)
				"X11", "OSX":
					_rec_copy_linux(file_name, project_path.text)
			file_name = dir.get_next()

	if selected_plugins.size() > 0:
		if not dir.dir_exists("%s/addons" % project_path.text):
			dir.make_dir("%s/addons" % project_path.text)

		for i in selected_plugins:
			match os:
				"Windows":
					_rec_copy_windows(i, "%s/addons" % project_path.text)
				"X11", "OSX":
					_rec_copy_linux(i, "%s/addons" % project_path.text)
	
	parent.open_project(project_path.text)

	queue_free()

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
			is_first = false
			continue
		c.free()
	
	for c in plugins.get_children():
		c.free()
	
	var popup_item: PackedScene = load("res://views/projects/new-project-popup/popup_item.tscn")
	
	for t in AppManager.cm.config().templates:
		var item = popup_item.instance()
		item.text = t.path
		item.button_group = template_group
		templates.add_child(item)
	
	for p in AppManager.cm.config().plugins:
		var item = popup_item.instance()
		item.text = p.path
		plugins.add_child(item)

func _rec_copy_windows(dir: String, path: String) -> void:
	# https://stackoverflow.com/questions/13314433/batch-file-to-copy-directories-recursively
	OS.execute("xcopy", ["/e", "/k", "/h", "/i", dir, path])

func _rec_copy_linux(dir: String, path: String) -> void:
	OS.execute("cp", ["-r", dir, path])

###############################################################################
# Public functions                                                            #
###############################################################################
