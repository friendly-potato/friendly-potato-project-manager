extends MarginContainer

const CONFIG_ITEM: PackedScene = preload("res://views/config/config_item.tscn")

const COL: int = 0

onready var filters: Tree = $VBoxContainer/HBoxContainer/HSplitContainer/VBoxContainer/FilterContainer/Filters
onready var configs: VBoxContainer = $VBoxContainer/HBoxContainer/HSplitContainer/ConfigContainer/ScrollContainer/Configs

var current_item: TreeItem

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	while not AppManager.cm.finished_loading:
		yield(get_tree(), "idle_frame")
	
	filters.connect("item_selected", self, "_on_item_selected")
	
	var root: TreeItem = filters.create_item()
	
	var general := _create_tree_item(root, "General")
	var projects := _create_tree_item(root, "Projects")
	var templates := _create_tree_item(root, "Templates")
	var plugins := _create_tree_item(root, "Plugins")
	
	var advanced := _create_tree_item(root, "Advanced", false)
	advanced.collapsed = true
	var danger_zone := _create_tree_item(advanced, "Danger Zone")
	danger_zone.set_tooltip(COL, "*whispers* danger zone")
	
	# Auto fill all config items into vbox configs

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_item_selected() -> void:
	var new_item: TreeItem = filters.get_selected()
	if new_item == current_item:
		current_item.deselect(COL)
	else:
		current_item = new_item

###############################################################################
# Private functions                                                           #
###############################################################################

func _create_tree_item(base: TreeItem, text: String, selectable: bool = true) -> TreeItem:
	var ti: TreeItem = filters.create_item(base)
	ti.set_text(COL, text)
	ti.set_expand_right(COL, true)
	ti.set_selectable(COL, selectable)
	
	return ti

func _create_config_item(id: String, value) -> ConfigItem:
	var ci: ConfigItem = CONFIG_ITEM.instance()
	
	# TODO stub
	
	return ci

###############################################################################
# Public functions                                                            #
###############################################################################
