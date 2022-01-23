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

var current_element: BaseHoverElement
var last_click_time: int = 0 # In msec

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	while not AppManager.cm.finished_loading:
		yield(get_tree(), "idle_frame")
	
# warning-ignore:return_value_discarded
	get_tree().root.connect("size_changed", self, "_on_size_changed")
	_on_size_changed()

###############################################################################
# Connections                                                                 #
###############################################################################

# warning-ignore:unused_argument
func _on_dir_selected(dir: String) -> void:
	# Should be overriden in implementations
	pass

func _on_size_changed() -> void:
	var size: Vector2 = OS.window_size
	if size.x < initial_normal_buttons_size * 5:
		normal_buttons_scroll.hide()
		top_buttons_scroll.show()
	else:
		normal_buttons_scroll.show()
		top_buttons_scroll.hide()

###############################################################################
# Private functions                                                           #
###############################################################################

func _copy_buttons() -> void:
	# Copy buttons and connections to top bar after hooking up connections
	for c in normal_buttons.get_children():
		if c is Button:
			top_buttons.add_child((c as Button).duplicate())
		elif c is HSeparator:
			top_buttons.add_child(VSeparator.new())

###############################################################################
# Public functions                                                            #
###############################################################################

func create_dir_selector(mode: int = FileDialog.MODE_OPEN_DIR) -> FileDialog:
	var popup := FileDialog.new()
	# Only allow for directories to be selected
	popup.mode = mode
	popup.access = FileDialog.ACCESS_FILESYSTEM
	popup.show_hidden_files = true
# warning-ignore:return_value_discarded
	popup.connect("popup_hide", AppManager, "destroy_node", [popup])
	
	return popup
