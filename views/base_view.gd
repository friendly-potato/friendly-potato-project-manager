class_name BaseView
extends MarginContainer

const DOUBLE_CLICK_TIME: int = 200 # In msec

onready var scroll: ScrollContainer = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer
onready var vbox: VBoxContainer = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer

onready var normal_buttons_scroll: ScrollContainer = $VBoxContainer/HBoxContainer/ButtonScroll
onready var normal_buttons: VBoxContainer = $VBoxContainer/HBoxContainer/ButtonScroll/Buttons
onready var top_buttons_scroll: ScrollContainer = $VBoxContainer/TopButtonScroll
onready var top_buttons: HBoxContainer = $VBoxContainer/TopButtonScroll/TopButtons
onready var initial_normal_buttons_size: int = normal_buttons_scroll.rect_min_size.x

var current_element: ProjectItem
var last_click_time: int = 0 # In msec

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	pass

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
