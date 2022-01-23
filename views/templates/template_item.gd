class_name TemplateItem
extends BaseHoverElement

class ParsedIgnorables:
	var has_error := false
	var error_line: int = -1
	var error_text: String = ""
	var error_description: String = ""
	
	var ignorables: Array = []
	
	func register_ignorable(text: String) -> void:
		if ignorables.has(text): # Not really necessary but w/e
			return
		ignorables.append(text)
	
	func register_error(line: int, text: String, description: String) -> void:
		has_error = true
		error_line = line
		error_text = text
		error_description = description
	
	func get_as_dict() -> Dictionary:
		var r := {}
		
		for i in get_property_list():
			var n: String = i.name
			if n in ["Reference", "script", "Script Variables"]:
				continue
			
			r[n] = get(n)
		
		return r
	
	func _to_string() -> String:
		return JSON.print(get_as_dict(), "\t")

const BAD_IGNORABLES: String = "__BAD_IGNORABLES__"

const BROWSE_IGNORABLES_POPUP_PATH: String = "res://views/templates/browse-ignorables-popup/browse_ignorables_popup.tscn"

var parent: BaseView

onready var buttons: HBoxContainer = $HBoxContainer/HBoxContainer
var store_locally_button: StoreLocallyButton
onready var edit_ignorables: Button = $HBoxContainer/HBoxContainer/EditIgnorables

onready var ignorables_container: HBoxContainer = $HBoxContainer/IgnorablesContainer
onready var text_edit: TextEdit = $HBoxContainer/IgnorablesContainer/TextEdit

var previous_ignorables_value: String = ""

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
# warning-ignore:return_value_discarded
	edit_ignorables.connect("pressed", self, "_on_edit_ignorables")
# warning-ignore:return_value_discarded
	$HBoxContainer/IgnorablesContainer/Browse.connect("pressed", self, "_on_ignorables_browse")
# warning-ignore:return_value_discarded
	$HBoxContainer/IgnorablesContainer/VBoxContainer/Confirm.connect("pressed", self, "_on_ignorables_confirm")
# warning-ignore:return_value_discarded
	$HBoxContainer/IgnorablesContainer/VBoxContainer/Cancel.connect("pressed", self, "_on_ignorables_cancel")
	
	label = $HBoxContainer/Label
	_set_label_text(label, path)
	
	buttons.add_child(store_locally_button)
	buttons.move_child(store_locally_button, 0)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked")

func _on_edit_ignorables() -> void:
	_toggle_ignorables()

func _on_ignorables_browse() -> void:
	var popup: BaseModdedFileDialog = load(BROWSE_IGNORABLES_POPUP_PATH).instance()
	popup.current_dir = path
# warning-ignore:return_value_discarded
	popup.connect("finished_selecting", self, "_on_finished_selecting")
	
	add_child(popup)

func _on_finished_selecting(items: Array) -> void:
	var joined_items: String = PoolStringArray(items).join("\n")
	text_edit.text = ("%s\n%s" % [text_edit.text, joined_items]).strip_edges()

func _on_ignorables_confirm() -> void:
	var ignorables := _parse_ignorables(text_edit, path)
	if ignorables.has_error:
		AppManager.logger.error("Bad ignorable at line %d\n- Description: %s\n- Content: %s" %
				[ignorables.error_line, ignorables.error_description, ignorables.error_text])
		return
	
	previous_ignorables_value = text_edit.text
	_toggle_ignorables()

func _on_ignorables_cancel() -> void:
	text_edit.text = previous_ignorables_value
	_toggle_ignorables()

###############################################################################
# Private functions                                                           #
###############################################################################

func _toggle_ignorables() -> void:
	edit_ignorables.visible = not edit_ignorables.visible
	ignorables_container.visible = not ignorables_container.visible

static func _parse_ignorables(te: TextEdit, path: String) -> ParsedIgnorables:
	var r := ParsedIgnorables.new()
	
	var d := Directory.new()
	
	var line_count := te.get_line_count()
	for i in line_count:
		var text := te.get_line(i)
		if text.empty():
			continue
		
		if not text.is_rel_path():
			r.register_error(i + 0, text, "File path expected")
			return r
		
		var full_path: String = "%s/%s" % [path, text]
		if not d.file_exists(full_path):
			r.register_error(i + 0, full_path, "File does not exist")
			return r
		
		r.register_ignorable(text)
	
	return r

###############################################################################
# Public functions                                                            #
###############################################################################
