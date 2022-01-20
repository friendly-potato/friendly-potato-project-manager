class_name BaseHoverElement
extends PanelContainer

var panel: StyleBoxFlat
var after_color: Color
var before_color: Color

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("gui_input", self, "_on_gui_input")
	
	panel = get("custom_styles/panel").duplicate(true)
	after_color = panel.bg_color
	before_color = after_color
	before_color.a *= 0.5
	panel.bg_color = before_color
	set("custom_styles/panel", panel)

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

###############################################################################
# Public functions                                                            #
###############################################################################

func unhover() -> void:
	panel.bg_color = before_color
	_set_panel_border_width(panel, 1)
