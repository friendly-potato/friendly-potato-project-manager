extends BaseView

const TEMPLATE_ITEM: PackedScene = preload("res://views/templates/template_item.tscn")

onready var templates: VBoxContainer = $VBoxContainer/HBoxContainer/PanelContainer/ScrollContainer/VBoxContainer

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Add.connect("pressed", self, "_on_add")
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Remove.connect("pressed", self, "_on_remove")
	
	while not AppManager.cm.finished_loading:
		yield(get_tree(), "idle_frame")
	
	for t in AppManager.cm.config().templates:
		templates.add_child(_create_template_item(t.path))

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_add() -> void:
	var popup := create_dir_selector()
	popup.connect("dir_selected", self, "_on_dir_selected")
	
	add_child(popup)
	popup.popup_centered_ratio()

func _on_dir_selected(dir: String) -> void:
	templates.add_child(_create_template_item(dir))
	AppManager.cm.config().add_template(dir)

func _on_remove() -> void:
	if current_element == null:
		return
	
	current_element.queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

func _create_template_item(path: String) -> Control:
	var item = TEMPLATE_ITEM.instance()
	item.parent = self
	item.text = path
	
	return item

###############################################################################
# Public functions                                                            #
###############################################################################
