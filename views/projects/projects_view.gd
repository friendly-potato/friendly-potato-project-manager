extends BaseView

# TODO testing
var data_path: String = "C:/Users/theaz/dev"

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	get_tree().root.connect("size_changed", self, "_on_size_changed")
	_on_size_changed()
	
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Run.connect("pressed", self, "_on_run")
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/New.connect("pressed", self, "_on_new")
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Import.connect("pressed", self, "_on_import")
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Scan.connect("pressed", self, "_on_scan")
	
	# Copy buttons and connections to top bar after hooking up connections
	for c in normal_buttons.get_children():
		if c is Button:
			top_buttons.add_child((c as Button).duplicate())
		elif c is HSeparator:
			top_buttons.add_child(VSeparator.new())
	
	_scan()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_size_changed() -> void:
	var size: Vector2 = OS.window_size
	if size.x < initial_normal_buttons_size * 5:
		normal_buttons_scroll.hide()
		top_buttons_scroll.show()
	else:
		normal_buttons_scroll.show()
		top_buttons_scroll.hide()

func _on_run() -> void:
	if current_element != null:
		OS.execute("C:/Users/theaz/apps/Godot_v3.4.2-stable_win64.exe", ["-e", "--path", current_element.path], false)
		get_tree().quit()

func _on_new() -> void:
	var popup: WindowDialog = load("res://views/projects/new-project-popup/new_project_popup.tscn").instance()
	add_child(popup)

func _on_import() -> void:
	pass

func _on_scan() -> void:
	for c in vbox.get_children():
		c.free()
	
	_scan()

func _on_project_item_clicked(pi: ProjectItem) -> void:
	var current_time: int = OS.get_ticks_msec()
	if (current_element == pi and abs(last_click_time - current_time) < DOUBLE_CLICK_TIME):
		OS.execute("C:/Users/theaz/apps/Godot_v3.4.2-stable_win64.exe", ["-e", "--path", pi.path], false)
		get_tree().quit()
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
	var dir := Directory.new()
	if dir.open(data_path) != OK:
		AppManager.logger.error("Unable to open data dir")
		# TODO show popup or something?
		return
	
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
			AppManager.logger.info("no project.godot found for %s/%s" % [data_path, file_name])
			continue
		
		var e: ProjectItem = load("res://views/projects/project_item.tscn").instance()
		vbox.add_child(e)
		e.label.text = file_name
		e.path = "%s/%s" % [data_path, file_name]
		e.connect("clicked", self, "_on_project_item_clicked", [e])
		
		file_name = dir.get_next()

###############################################################################
# Public functions                                                            #
###############################################################################