extends LoadableCopyView

const PLUGIN_ITEM: PackedScene = preload("res://views/plugins/plugin_item.tscn")
const PLUGIN_BROWSE: PackedScene = preload("res://views/plugins/add-plugin-popup/add_plugin_popup.tscn")

const PLUGIN_CFG: String = "plugin.cfg"

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
# warning-ignore:return_value_discarded
	AppManager.sb.connect("rescan_triggered", self, "_on_rescan_triggered")
	
	_scan()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_rescan_triggered() -> void:
	for item in items.get_children():
		item.free()
	
	_scan()

func _on_add() -> void:
	var popup: BaseModdedFileDialog = PLUGIN_BROWSE.instance()
	popup.current_dir = AppManager.cm.config().default_search_path
# warning-ignore:return_value_discarded
	popup.connect("finished_selecting", self, "_on_dir_selected")

	add_child(popup)

func _on_remove() -> void:
	if current_element == null:
		return
	
	AppManager.cm.config().remove_plugin(current_element.path)
	
	current_element.queue_free()
	current_element = null

###############################################################################
# Private functions                                                           #
###############################################################################

func _scan() -> void:
	for i in AppManager.cm.config().plugins:
		var item: PluginItem = _add_item(i.path)
		item.store_locally_button.path = i.path
		if i.is_local_copy:
			item.store_locally_button.state = StoreLocallyButton.State.STORED
		else:
			item.store_locally_button.state = StoreLocallyButton.State.START
		items.add_child(item)

func _add_item(path: String) -> Control:
	var item: PluginItem = PLUGIN_ITEM.instance()
	
	var sl := StoreLocallyButton.new()
	sl.path = path
	sl.item_type = StoreLocallyButton.ItemType.PLUGIN
	sl.state = StoreLocallyButton.State.START
	
	item.store_locally_button = sl
	
	item.path = path
# warning-ignore:return_value_discarded
	item.connect("clicked", self, "_on_item_clicked", [item])
	
	return item

func _add_to_config(path: String) -> void:
	AppManager.cm.config().add_plugin(path)

###############################################################################
# Public functions                                                            #
###############################################################################
