class_name MissingDataPopup
extends WindowDialog

# Project name
onready var project_name_line_edit: LineEdit = $VBoxContainer/ProjectNameContainer/HBoxContainer/LineEdit

# Exe
onready var exe_line_edit: LineEdit = $VBoxContainer/ExeContainer/HBoxContainer/LineEdit
onready var exe_browse: Button = $VBoxContainer/ExeContainer/HBoxContainer/Browse

# Default directory
onready var directory_line_edit: LineEdit = $VBoxContainer/DirectoryContainer/HBoxContainer/LineEdit
onready var directory_browse: Button = $VBoxContainer/DirectoryContainer/HBoxContainer/Browse

# Buttons
onready var accept: Button = $VBoxContainer/ButtonContainer/Accept
onready var skip: Button = $VBoxContainer/ButtonContainer/Skip
onready var skip_label: Label = $VBoxContainer/SkipLabel

enum SkipState {
	NONE = 0,
	START,
	CONFIRM
}

var skip_state: int = SkipState.START
const SKIP_START: String = "Skip"
const SKIP_CONFIRM: String = "Confirm"

var dir := Directory.new()

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	project_name_line_edit.connect("text_changed", self, "_on_project_name_line_edit_text_changed")
	project_name_line_edit.text = AppManager.cm.config().default_new_project_name
	
	exe_line_edit.connect("text_changed", self, "_on_exe_line_edit_text_changed")
	exe_browse.connect("pressed", self, "_on_exe_browse")
	
	directory_line_edit.connect("text_changed", self, "_on_directory_line_edit_text_changed")
	directory_line_edit.text = AppManager.cm.config().default_search_path
	directory_browse.connect("pressed", self, "_on_directory_browse")
	
	accept.connect("pressed", self, "_on_accept")
	accept.disabled = true
	
	skip.rect_min_size.x = skip.rect_size.x
	skip.text = SKIP_START
	skip.connect("pressed", self, "_on_skip")
	skip.connect("mouse_exited", self, "_on_skip_mouse_exited")
	
	get_close_button().hide()
	connect("popup_hide", self, "_on_prevent_hide")
	
	popup_centered_ratio()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_project_name_line_edit_text_changed(text: String) -> void:
	if not text.empty():
		accept.disabled = false
	else:
		accept.disabled = true

func _on_exe_line_edit_text_changed(text: String) -> void:
	if dir.file_exists(text):
		accept.disabled = false
	else:
		accept.disabled = true

func _on_exe_browse() -> void:
	var popup: FileDialog = AppManager.create_dir_select(FileDialog.MODE_OPEN_FILE)
	popup.connect("file_selected", self, "_on_exe_selected")
	
	add_child(popup)
	
	popup.current_dir = directory_line_edit.text if exe_line_edit.text.empty() else exe_line_edit.text
	popup.popup_centered_ratio()

func _on_exe_selected(path: String) -> void:
	exe_line_edit.text = path
	_on_exe_line_edit_text_changed(path)

func _on_directory_line_edit_text_changed(text: String) -> void:
	if dir.dir_exists(text):
		accept.disabled = false
	else:
		accept.disabled = true

func _on_directory_browse() -> void:
	var popup: FileDialog = AppManager.create_dir_select(FileDialog.MODE_OPEN_DIR)
	popup.connect("dir_selected", self, "_on_directory_selected")
	
	add_child(popup)
	
	popup.current_dir = directory_line_edit.text
	popup.popup_centered_ratio()

func _on_directory_selected(path: String) -> void:
	directory_line_edit.text = path
	_on_directory_line_edit_text_changed(path)

func _on_accept() -> void:
	AppManager.cm.config().default_new_project_name = project_name_line_edit.text
	AppManager.cm.config().default_godot_executable = exe_line_edit.text
	AppManager.cm.config().default_search_path = directory_line_edit.text
	queue_free()

func _on_skip() -> void:
	match skip_state:
		SkipState.START:
			skip.text = SKIP_CONFIRM
			skip_state = SkipState.CONFIRM
			skip_label.show()
		SkipState.CONFIRM:
			queue_free()

func _on_skip_mouse_exited() -> void:
	skip_state = SkipState.START
	skip.text = SKIP_START
	skip_label.hide()

func _on_prevent_hide() -> void:
	self.show()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
