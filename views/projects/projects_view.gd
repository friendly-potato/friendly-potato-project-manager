extends BaseView

const PROJECT_ITEM: PackedScene = preload("res://views/projects/project_item.tscn")
const NEW_PROJECT_POPUP: PackedScene = preload("res://views/projects/new-project-popup/new_project_popup.tscn")

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
# warning-ignore:return_value_discarded
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Run.connect("pressed", self, "_on_run")
# warning-ignore:return_value_discarded
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/New.connect("pressed", self, "_on_new")
# warning-ignore:return_value_discarded
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Import.connect("pressed", self, "_on_import")
# warning-ignore:return_value_discarded
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Scan.connect("pressed", self, "_on_scan")
	
# warning-ignore:return_value_discarded
	AppManager.sb.connect("rescan_triggered", self, "_on_rescan_triggered")
	
	_copy_buttons()
	
	_scan()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_rescan_triggered() -> void:
	for c in vbox.get_children():
		c.free()
	
	_scan()

func _on_size_changed() -> void:
	._on_size_changed()

func _on_run() -> void:
	if current_element != null:
		_run(current_element.path)

func _on_new() -> void:
	var popup: WindowDialog = NEW_PROJECT_POPUP.instance()
	popup.parent = self
	add_child(popup)

func _on_import() -> void:
	pass

func _on_scan() -> void:
	_on_rescan_triggered()

func _on_project_item_clicked(pi: ProjectItem) -> void:
	var current_time: int = OS.get_ticks_msec()
	if (current_element == pi and abs(last_click_time - current_time) < DOUBLE_CLICK_TIME):
		open_project(pi.path)
	else:
		if current_element != null:
			current_element.before_color = current_element.changed_color
			current_element.unhover()
		current_element = pi
		current_element.before_color = current_element.after_color
		last_click_time = current_time

###############################################################################
# Private functions                                                           #
###############################################################################

func _scan() -> void:
	var data_path: String = AppManager.cm.config().default_search_path
	
	var dir := Directory.new()
	if dir.open(data_path) != OK:
		AppManager.logger.error("Unable to open data dir")
		# TODO show popup or something?
		return
	
	# warning-ignore:return_value_discarded
	dir.list_dir_begin(true, true)
	
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			file_name = dir.get_next()
			continue
		
		# Just assume everything is a godot 3 project for now
		# TODO parse project.godot for engine version
		if not dir.file_exists("%s/%s/project.godot" % [data_path, file_name]):
			file_name = dir.get_next()
			AppManager.logger.debug("no project.godot found for %s/%s" % [data_path, file_name])
			continue
		
		var e: ProjectItem = PROJECT_ITEM.instance()
		e.path = "%s/%s" % [data_path, file_name]
		# warning-ignore:return_value_discarded
		e.connect("clicked", self, "_on_project_item_clicked", [e])
		vbox.add_child(e)
		
		file_name = dir.get_next()

func _run(path: String) -> void:
	# warning-ignore:return_value_discarded
	OS.execute(AppManager.cm.config().default_godot_executable, ["-e", "--path", path], false)
	get_tree().quit()

###############################################################################
# Public functions                                                            #
###############################################################################

func open_project(path: String) -> void:
	_run(path)
