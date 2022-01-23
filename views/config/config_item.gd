class_name ConfigItem
extends HBoxContainer

signal changed(id, value)
signal changed_typed(id, value, typing)

enum ConfigType {
	NONE = 0,
	TEXT,
	TEXT_AREA,
	CHECK,
	DROP_DOWN,
	BUTTON
}

enum Filters {
	NONE = 0,
	GENERAL,
	PROJECTS,
	TEMPLATES,
	PLUGINS,
	ADVANCED
}

class Payload extends Reference:
	# Technically the name but calling it id to avoid name conflicts
	var id: String
	var type: int # ConfigType
	var value # Duck typed

var data: Payload

var filter: int = Filters.NONE

onready var label: Label = $Label
var item: Control

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	label.text = data.id.capitalize()
	match data.type:
		ConfigType.TEXT:
			item = LineEdit.new()
			item.text = str(data.value)
# warning-ignore:return_value_discarded
			item.connect("text_changed", self, "_on_line_edit_text_changed")
		ConfigType.TEXT_AREA:
			item = TextEdit.new()
			item.text = data.value
			item.rect_min_size.y = 100
# warning-ignore:return_value_discarded
			item.connect("text_changed", self, "_on_text_edit_text_changed")
		ConfigType.CHECK:
			item = CheckBox.new()
			item.pressed = data.value
# warning-ignore:return_value_discarded
			item.connect("toggled", self, "_on_check_box_toggled")
		ConfigType.DROP_DOWN:
			item = PopupMenu.new()
			for i in data.value:
				item.add_item(i)
# warning-ignore:return_value_discarded
			item.connect("index_pressed", self, "_on_popup_menu_index_pressed")
		ConfigType.BUTTON:
			item = Button.new()
# warning-ignore:return_value_discarded
			item.connect("pressed", self, "_on_button_pressed")
		_:
			AppManager.logger.error("Unrecognized config item type: %s" % data.type)
			return
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(item)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_line_edit_text_changed(text: String) -> void:
	if text.empty():
		return
	emit_signal("changed_typed", data.id, text, typeof(data.value))

func _on_text_edit_text_changed() -> void:
	"""
	TextEdit is only used for arrays, so convert back to an array
	"""
	if item.text.empty():
		return
	var text: PoolStringArray = item.text.split("\n")
	var r := []
	for t in text:
		if not t.empty():
			r.append(t)
	emit_signal("changed", data.id, r)

func _on_check_box_toggled(state: bool) -> void:
	emit_signal("changed", data.id, state)

func _on_popup_menu_index_pressed(idx: int) -> void:
	emit_signal("changed", data.id, item.get_item_text(idx))

func _on_button_pressed() -> void:
	emit_signal("changed", data.id, true)

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
