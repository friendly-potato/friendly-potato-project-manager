extends WindowDialog

const CONFIRM: String = "Confirm"
const PLUGIN_EXISTS: String = "Plugin already exists"

onready var plugins: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer

var dir := Directory.new()

var project_path: String

var last_text: String
var last_button: Button

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	var show_full_file_paths := AppManager.cm.config().show_full_file_paths
	for i in AppManager.cm.config().plugins:
		var b := Button.new()
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.text = i.path if show_full_file_paths else i.path.get_file()
		if dir.dir_exists("%s/addons/%s" % [project_path, i.path.get_file()]):
			b.text = "%s - %s" % [PLUGIN_EXISTS, b.text]
			b.disabled = true
		else:
			b.connect("pressed", self, "_on_pressed", [b, i.path])
			b.connect("mouse_exited", self, "_on_mouse_exited")
		
		plugins.add_child(b)
	
	connect("popup_hide", self, "_on_hide")
	$VBoxContainer/ButtonContainer/Cancel.connect("pressed", self, "_on_hide")
	
	popup_centered_ratio()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_pressed(button: Button, path: String) -> void:
	if last_button == null:
		last_button = button
		last_text = button.text
		button.text = CONFIRM
	elif last_button == button:
		match OS.get_name().to_lower():
			"windows":
				FileSystem.rec_copy_windows(path, "%s/addons/%s" % [project_path, path.get_file()])
			"x11", "osx":
				FileSystem.rec_copy_linux(path, "%s/addons/%s" % [project_path, path.get_file()])
		queue_free()
	else:
		last_button.text = last_text
		last_button = button
		last_text = button.text
		button.text = CONFIRM

func _on_mouse_exited() -> void:
	if last_button != null:
		last_button.text = last_text
		last_button = null

func _on_hide() -> void:
	queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
