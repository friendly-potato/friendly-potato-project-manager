extends MarginContainer

const CONFIG_ITEM: PackedScene = preload("res://views/config/config_item.tscn")

const COL: int = 0

const IGNORED_CONFIGS: Array = ["templates", "plugins", "path", "type", "known_projects"]
const GENERAL: String = "General"
const GENERAL_ITEMS: Array = [
	"default_search_path",
	"show_full_file_paths"
]
const PROJECTS: String = "Project"
const PROJECT_ITEMS: Array = [
	"default_new_project_name"
]
const TEMPLATES: String = "Template"
const TEMPLATE_ITEMS: Array = [
	"global_template_items_to_ignore"
]
const PLUGINS: String = "Plugins"
const PLUGIN_ITEMS: Array = [
	
]
const ADVANCED: String = "Advanced"
const DANGER_ZONE: String = "Danger Zone"

onready var filters: Tree = $VBoxContainer/HBoxContainer/HSplitContainer/VBoxContainer/FilterContainer/Filters
onready var configs: VBoxContainer = $VBoxContainer/HBoxContainer/HSplitContainer/ConfigContainer/ScrollContainer/Configs
onready var search: LineEdit = $VBoxContainer/Search/LineEdit

var current_item: TreeItem

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	while not AppManager.cm.finished_loading:
		yield(get_tree(), "idle_frame")
	
	# warning-ignore:return_value_discarded
	search.connect("text_changed", self, "_on_text_changed")
	
	# warning-ignore:return_value_discarded
	filters.connect("item_selected", self, "_on_item_selected")
	
	var root: TreeItem = filters.create_item()
	
	# warning-ignore:unused_variable
	var general := _create_tree_item(root, GENERAL)
	# warning-ignore:unused_variable
	var projects := _create_tree_item(root, PROJECTS)
	# warning-ignore:unused_variable
	var templates := _create_tree_item(root, TEMPLATES)
	# warning-ignore:unused_variable
	var plugins := _create_tree_item(root, PLUGINS)
	
	var advanced := _create_tree_item(root, ADVANCED, false)
	advanced.collapsed = true
	var danger_zone := _create_tree_item(advanced, DANGER_ZONE)
	danger_zone.set_tooltip(COL, "*whispers* danger zone")
	
	# Auto fill all config items into vbox configs
	var config_dict := AppManager.cm.config().get_as_dict()
	for key in config_dict.keys():
		if key in IGNORED_CONFIGS:
			continue
		
		var ci := _create_config_item(key, config_dict[key])
		configs.add_child(ci)

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_item_selected() -> void:
	var new_item: TreeItem = filters.get_selected()
	if (current_item != null and new_item == current_item):
		current_item.deselect(COL)
		current_item = null
		for c in configs.get_children():
			c.show()
	else:
		current_item = new_item
		var filter_text: String = current_item.get_text(COL)
		for c in configs.get_children():
			if c.filter != _text_to_filter(filter_text):
				c.hide()
			else:
				c.show()

func _on_config_item_changed(id: String, value) -> void:
	_update_config(id, value)

func _on_config_item_changed_typed(id: String, value, typing: int) -> void:
	var val
	match typing:
		TYPE_INT:
			val = int(value)
		TYPE_REAL:
			val = float(value)
		TYPE_STRING:
			val = value
		TYPE_BOOL:
			val = bool(value)
		_:
			AppManager.logger.error("Unhandled type: %d" % typing)
	_update_config(id, val)

func _on_text_changed(text: String) -> void:
	if text.empty():
		for c in configs.get_children():
			c.show()
		return
	for c in configs.get_children():
		if c.label.text.to_lower().similarity(text.to_lower()) > 0.5:
			c.show()
		else:
			c.hide()
		return

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
	
	var payload := ConfigItem.Payload.new()
	payload.id = id
	
	match typeof(value):
		TYPE_STRING, TYPE_INT, TYPE_REAL:
			payload.type = ConfigItem.ConfigType.TEXT
			payload.value = value
			# warning-ignore:return_value_discarded
			ci.connect("changed_typed", self, "_on_config_item_changed_typed")
		TYPE_BOOL:
			payload.type = ConfigItem.ConfigType.CHECK
			payload.value = value
			# warning-ignore:return_value_discarded
			ci.connect("changed", self, "_on_config_item_changed")
		TYPE_ARRAY:
			payload.type = ConfigItem.ConfigType.TEXT_AREA
			var joined := PoolStringArray(value).join("\n").strip_edges()
			payload.value = joined
			# warning-ignore:return_value_discarded
			ci.connect("changed", self, "_on_config_item_changed")
		TYPE_DICTIONARY:
			pass
	
	ci.data = payload
	_apply_filters(ci, id)
	
	return ci

func _apply_filters(ci: ConfigItem, id: String) -> void:
	if id in GENERAL_ITEMS:
		ci.filter = ConfigItem.Filters.GENERAL
	elif id in PROJECT_ITEMS:
		ci.filter = ConfigItem.Filters.PROJECTS
	elif id in TEMPLATE_ITEMS:
		ci.filter = ConfigItem.Filters.TEMPLATES
	elif id in PLUGIN_ITEMS:
		ci.filter = ConfigItem.Filters.PLUGINS

func _text_to_filter(text: String) -> int:
	match text:
		GENERAL:
			return ConfigItem.Filters.GENERAL
		PROJECTS:
			return ConfigItem.Filters.PROJECTS
		TEMPLATES:
			return ConfigItem.Filters.TEMPLATES
		PLUGINS:
			return ConfigItem.Filters.PLUGINS
		_: # Everything is root level except for advanced
			return ConfigItem.Filters.ADVANCED

func _update_config(id: String, value) -> void:
	AppManager.cm.config().set(id, value)
	AppManager.cm.dirty = true

###############################################################################
# Public functions                                                            #
###############################################################################
