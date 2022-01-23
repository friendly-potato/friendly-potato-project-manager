class_name ConfigItem
extends HBoxContainer

signal changed(id, value)

enum ConfigType {
	NONE = 0,
	TEXT,
	CHECK,
	DROP_DOWN,
	BUTTON
}

class Payload extends Reference:
	# Technically the name but calling it id to avoid name conflicts
	var id: String
	var type: int # ConfigType
	var value # Duck typed

var data: Payload

onready var label: Label = $Label
var item: Control

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	label.text = data.id
	match data.type:
		ConfigType.TEXT:
			item = LineEdit.new()
			item.text = data.value
			item.connect("text_changed", self, "_on_line_edit_text_changed")
		ConfigType.CHECK:
			item = CheckBox.new()
			item.pressed = data.value
			item.connect("toggled", self, "_on_check_box_toggled")
		ConfigType.DROP_DOWN:
			item = PopupMenu.new()
			for i in data.value:
				item.add_item(i)
			item.connect("index_pressed", self, "_on_popup_menu_index_pressed")
		ConfigType.BUTTON:
			item = Button.new()
			item.connect("pressed", self, "_on_button_pressed")
		_:
			AppManager.logger.error("Unrecognized config item type: %s" % data.type)
			return
	add_child(item)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_line_edit_text_changed(text: String) -> void:
	emit_signal("changed", label.text, text)

func _on_check_box_toggled(state: bool) -> void:
	emit_signal("changed", label.text, state)

func _on_popup_menu_index_pressed(idx: int) -> void:
	emit_signal("changed", label.text, item.get_item_text(idx))

func _on_button_pressed() -> void:
	emit_signal("changed", label.text, true)

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
