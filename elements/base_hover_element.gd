class_name BaseHoverElement
extends PanelContainer

# warning-ignore:unused_signal
signal clicked()

var panel: StyleBoxFlat
var after_color: Color
var before_color: Color
var changed_color: Color

var label: Label

var path: String

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	# warning-ignore:return_value_discarded
	connect("mouse_entered", self, "_on_mouse_entered")
	# warning-ignore:return_value_discarded
	connect("mouse_exited", self, "_on_mouse_exited")
	# warning-ignore:return_value_discarded
	connect("gui_input", self, "_on_gui_input")
	
	panel = get("custom_styles/panel").duplicate(true)
	after_color = panel.bg_color
	before_color = after_color
	before_color.a *= 0.5
	panel.bg_color = before_color
	set("custom_styles/panel", panel)
	
	changed_color = before_color

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_gui_input(_event: InputEvent) -> void:
	# Dummy impl
	pass

func _on_mouse_entered() -> void:
	panel.bg_color = after_color
	_set_panel_border_width(panel, 2)

func _on_mouse_exited() -> void:
	unhover()

###############################################################################
# Private functions                                                           #
###############################################################################

static func _set_panel_border_width(p: StyleBoxFlat, width: int) -> void:
	p.border_width_left = width
	p.border_width_right = width
	p.border_width_top = width
	p.border_width_bottom = width

static func _set_label_text(l: Label, t: String) -> void:
	l.text = t if AppManager.cm.config().show_full_file_paths else t.get_file()

###############################################################################
# Public functions                                                            #
###############################################################################

func unhover() -> void:
	panel.bg_color = before_color
	_set_panel_border_width(panel, 1)
