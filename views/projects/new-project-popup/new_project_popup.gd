extends WindowDialog

const POPUP_ITEM: PackedScene = preload("res://views/projects/new-project-popup/popup_item.tscn")

var parent: BaseView

onready var project_name: LineEdit = $VBoxContainer/ScrollContainer/VBoxContainer/ProjectLineEdit
onready var project_path: LineEdit = $VBoxContainer/ScrollContainer/VBoxContainer/ProjectPathContainer/ProjectPathLineEdit

onready var create_edit: Button = $VBoxContainer/HBoxContainer/CreateEdit
onready var create: Button = $VBoxContainer/HBoxContainer/Create
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
	# warning-ignore:return_value_discarded
	connect("popup_hide", AppManager, "destroy_node", [self])
	# warning-ignore:return_value_discarded
	project_path.connect("text_changed", self, "_on_project_path_changed")
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/GL3/CheckBox.group = button_group
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/GL2/CheckBox.group = button_group
	
	# warning-ignore:return_value_discarded
	$VBoxContainer/ScrollContainer/VBoxContainer/ProjectPathContainer/Button.connect("pressed", self, "_on_browse")
	
	project_name.text = AppManager.cm.config().default_new_project_name
	project_path.text = AppManager.cm.config().default_search_path
	
	# Add default (empty) project template first
	var default_template = POPUP_ITEM.instance()
	default_template.text = "Default"
	default_template.initial_pressed_value = true
	default_template.button_group = template_group
	templates.add_child(default_template)
	
	_populate_templates_plugins()
	
	# warning-ignore:return_value_discarded
	create_edit.connect("pressed", self, "_on_create_edit")
	# warning-ignore:return_value_discarded
	create.connect("pressed", self, "_on_create")
	# warning-ignore:return_value_discarded
	cancel.connect("pressed", AppManager, "destroy_node", [self])
	
	popup_centered_ratio()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_browse() -> void:
	var popup: FileDialog = parent.create_dir_selector()
	# warning-ignore:return_value_discarded
	popup.connect("dir_selected", self, "_on_dir_selected")
	popup.current_dir = AppManager.cm.config().default_search_path
	
	add_child(popup)
	popup.popup_centered_ratio()

func _on_create() -> void:
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
	
	# TODO currently the folder must exist beforehand
	var dir := Directory.new()
	if not dir.dir_exists(project_path.text):
		AppManager.logger.error("Path does not exist: %s\nDeclining to implicitly create new directory" % project_path.text)
		return
	
	if dir.open(project_path.text) != OK:
		AppManager.logger.error("Unable to check proposed project directory")
		return
	
	# warning-ignore:return_value_discarded
	dir.list_dir_begin(true, false)
	
	var count: int = 0
	var file_name: String = dir.get_next()
	while file_name != "":
		count += 1
		file_name = dir.get_next()
	
	if count != 0:
		AppManager.logger.error("Declining to create project in non-empty directory")
		return

	var os: String = OS.get_name().to_lower()
	match os:
		"windows":
			# warning-ignore:return_value_discarded
			OS.execute("type", ["nul", ">", "%s/project.godot" % project_path.text])
		"x11", "osx":
			# warning-ignore:return_value_discarded
			OS.execute("touch", ["%s/project.godot" % project_path.text])
	
	if template != "Default":
		var t_dir := Directory.new()
		if t_dir.open(template) != OK:
			AppManager.logger.error("Unable to open template: %s" % template)
			return

		_copy_template_recursive(
			template,
			project_path.text,
			AppManager.cm.config().find_template(template),
			AppManager.cm.config().global_template_items_to_ignore)
		
		AppManager.logger.debug("Finished copying templates")

	if selected_plugins.size() > 0:
		if not dir.dir_exists("%s/addons" % project_path.text):
			# warning-ignore:return_value_discarded
			dir.make_dir("%s/addons" % project_path.text)

		for i in selected_plugins:
			match os:
				"windows":
					FileSystem.rec_copy_windows(i, "%s/addons/%s" % [project_path.text, i.get_file()])
				"x11", "osx":
					FileSystem.rec_copy_linux(i, "%s/addons/%s" % [project_path.text, i.get_file()])
		
		AppManager.logger.debug("Finished copying templates")
	
	AppManager.cm.config().add_known_project(project_path.text)
	AppManager.sb.broadcast_rescan_triggered()

func _on_create_edit() -> void:
	_on_create()
	
	parent.open_project(project_path.text)

	queue_free()

func _on_dir_selected(dir: String) -> void:
	project_path.text = dir
	_on_project_path_changed(dir)

func _on_project_path_changed(text: String) -> void:
	if text.empty():
		create_edit.disabled = true
		create.disabled = true
		return
	
	var dir := Directory.new()
	if not dir.dir_exists(text):
		create_edit.disabled = true
		create.disabled = true
		return
	
	create_edit.disabled = false
	create.disabled = false

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
	
	for t in AppManager.cm.config().templates:
		var item = POPUP_ITEM.instance()
		item.text = t.path
		item.button_group = template_group
		templates.add_child(item)
	
	for p in AppManager.cm.config().plugins:
		var item = POPUP_ITEM.instance()
		item.text = p.path
		plugins.add_child(item)

func _copy_template_recursive(
		from_base_path: String,
		to_base_path: String,
		template: ConfigManager.Template,
		global_items_to_ignore: Array,
		rel_path_chain: String = "") -> void:
	var dir := Directory.new()
	if dir.open("%s/%s" % [from_base_path, rel_path_chain]) != OK:
		AppManager.logger.error("Unable to open path: %s/%s" % [from_base_path, rel_path_chain])
		return
	
	if not dir.dir_exists("%s/%s" % [to_base_path, rel_path_chain]):
		var t_dir := Directory.new()
		if t_dir.open(to_base_path) != OK:
			AppManager.logger.error("Unable to open %s" % to_base_path)
			return

		if t_dir.make_dir(rel_path_chain):
			AppManager.logger.error("Unable to create dir %s/%s" % [
				to_base_path, rel_path_chain])
			return

	if dir.list_dir_begin(true, false) != OK:
		AppManager.logger.error("Unable to stream directory")
		return
	
	var item_name: String = dir.get_next()
	while item_name != "":
		var constructed_path: String = "%s/%s" % [
			rel_path_chain, item_name] if not rel_path_chain.empty() else item_name

		if (constructed_path in global_items_to_ignore or
				constructed_path in template.items_to_ignore):
			item_name = dir.get_next()
			continue
		
		if dir.current_is_dir():
			_copy_template_recursive(
				from_base_path,
				to_base_path,
				template,
				global_items_to_ignore,
				constructed_path)
			item_name = dir.get_next()
			continue

		if dir.copy(
				"%s/%s" % [from_base_path, constructed_path],
				"%s/%s" % [to_base_path, constructed_path]) != OK:
			AppManager.logger.error(
				"Unable to copy %s/%s to %s/%s" % [
					from_base_path,
					constructed_path,
					to_base_path,
					constructed_path])
			item_name = dir.get_next()
			continue
		
		item_name = dir.get_next()

###############################################################################
# Public functions                                                            #
###############################################################################
