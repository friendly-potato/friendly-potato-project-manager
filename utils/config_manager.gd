class_name ConfigManager
extends Reference

enum LoadableType {
	NONE, # Unreachable
	LOADABLE, # Unreachable
	CONFIG_DATA,
	TEMPLATE,
	PLUGIN
}

# Errors
const LOADING_ERROR: String = "Invalid data encountered, loading halted"
const LOADABLE_NOT_FOUND_ERROR: String = "Loadable not found"
const LOADABLE_ALREADY_EXISTS_ERROR: String = "Attempted to created duplicate loadable"

const CONFIG_UNABLE_TO_WRITE_ERROR: String = "Unable to open config file for writing"
const CONFIG_UNABLE_TO_OPEN_ERROR: String = "Config file not found, using new config"
const CONFIG_UNABLE_TO_READ_ERROR: String = "Unable to read config file"

# Loading keys
const TYPE: String = "type"

const CONFIG_NAME: String = "config.json"

var _config_path: String # For switching between debug config and release config
var _current_config: ConfigData

# Metadata
var dirty := false
var finished_loading := false

class Loadable:
	var type: int # LoadableType
	var path: String
	
	func get_as_dict() -> Dictionary:
		var d := {}
		
		for i in get_property_list():
			var n: String = i.name
			if n in ["Reference", "script", "Script Variables"]:
				continue
			
			var val = get(n)
			
			match typeof(val):
				TYPE_ARRAY:
					var transformed_value := []
					for j in val:
						if j is Loadable:
							transformed_value.append(j.get_as_dict())
						else:
							transformed_value.append(j)
					d[n] = transformed_value
				TYPE_DICTIONARY:
					var transformed_value := {}
					for j_key in val.keys():
						var j = val[j_key]
						if j is Loadable:
							transformed_value[j_key] = j.get_as_dict()
						else:
							transformed_value[j_key] = j
					d[n] = transformed_value
				_:
					d[n] = val
		
		return d
	
	func get_as_json() -> String:
		return JSON.print(get_as_dict(), "\t")
	
	func load_from_dict(d: Dictionary) -> void:
		for k in d.keys():
			var v = d[k]
			
			match typeof(v):
				TYPE_ARRAY: # Arrays can only contain dicts or primitives
					var transformed_value := []
					for i in v:
						match typeof(i):
							TYPE_DICTIONARY:
								if not i.has(TYPE):
									AppManager.logger.error(LOADING_ERROR)
									return
								match i[TYPE]:
									LoadableType.TEMPLATE:
										var t := Template.new()
										t.load_from_dict(i)
										transformed_value.append(t)
									LoadableType.PLUGIN:
										var p := Plugin.new()
										p.load_from_dict(i)
										transformed_value.append(p)
									_:
										AppManager.logger.error(LOADING_ERROR)
										return
							TYPE_ARRAY:
								AppManager.logger.error(LOADING_ERROR)
								return
							_:
								transformed_value.append(i)
					set(k, transformed_value)
				TYPE_DICTIONARY:
					if v.has(TYPE): # Currently an error to have a template/plugin at config root
						AppManager.logger.error(LOADING_ERROR)
						return
					set(k, v)
				_:
					set(k, v)
		pass
	
	func _duplicate(t):
		var r
		if t is ConfigData:
			r = ConfigData.new()
		elif t is Template:
			r = Template.new()
		elif t is Plugin:
			r = Plugin.new()
		
		t.get_type()
		
		for i in get_property_list():
			var n : String = i.name
			if n in ["Reference", "script", "Script Variables"]:
				continue
			
			r.set(n, get(n))
		
		return r
	
	func _to_string() -> String:
		return get_as_json()

class LoadableCopy extends Loadable:
	# Whether the item is copied to the user data directory or just
	# referenced somewhere else in the file system
	var is_local_copy := false
	var old_path: String

class Template extends LoadableCopy:
	"""
	Copying a template only goes 1 level deep. Files and directories are both copied.
	"""
	var items_to_ignore: Array # String
	
	func _init(
			p_path: String = "",
			p_items_to_ignore: Array = []) -> void:
		type = LoadableType.TEMPLATE
		
		path = p_path
		old_path = p_path
		items_to_ignore = p_items_to_ignore
	
	func duplicate() -> Template:
		return _duplicate(self)

class Plugin extends LoadableCopy:
	"""
	Plugins must be located in a folder. That folder is then recursively copied.
	"""
	func _init(p_path: String = "") -> void:
		type = LoadableType.PLUGIN
		
		path = p_path
		old_path = p_path
	
	func duplicate() -> Plugin:
		return _duplicate(self)

class ConfigData extends Loadable:
	var templates: Array = [] # Template
	var global_template_items_to_ignore: Array = [".git", ".import", "project.godot"] # String
	
	var plugins: Array = [] # Plugin
	
	var default_new_project_name: String
	
	var default_search_path: String
	var show_full_file_paths := false
	var known_projects: Array = [] # String paths
	
	func _init() -> void:
		path = "root"
		type = LoadableType.CONFIG_DATA
		
		default_new_project_name = "New Project"
		default_search_path = _determine_default_search_path()

	func load_from_json(json_string: String) -> int:
		"""
		Converts json string to a dictionary with the appropriate values
		"""
		var json_result = parse_json(json_string)

		if typeof(json_result) != TYPE_DICTIONARY:
			AppManager.logger.error("Invalid config data loaded")
			return FAILED

		for key in (json_result as Dictionary).keys():
			var data = json_result[key]
			
			match key.to_lower():
				"templates":
					var l := []
					for i in data:
						var t := Template.new()
						t.load_from_dict(i)
						l.append(t)
					set(key, l)
				"plugins":
					var l := []
					for i in data:
						var p := Plugin.new()
						p.load_from_dict(i)
						l.append(p)
					set(key, l)
				_:
					set(key, data)
		
		return OK

	func load_from_dict(json_dict: Dictionary) -> void:
		"""
		Since we are using the class as a struct, we can't just set the
		dict to a value
		"""
		for key in json_dict.keys():
			set(key, json_dict[key])

	func duplicate() -> ConfigData:
		return _duplicate(self)
	
	func add_template(
			path: String,
			items_to_ignore: Array = []) -> void:
		# Do not add duplicates
		if _find_matching_loadable("path", path, templates) == OK:
			return
		
		templates.append(Template.new(path, items_to_ignore))
	
	func add_plugin(path: String) -> void:
		# Do not add duplicates
		if _find_matching_loadable("path", path, plugins) == OK:
			return
		
		plugins.append(Plugin.new(path))
	
	func edit_template(path: String, data: Dictionary) -> void:
		_edit_loadable(path, data, templates)
	
	func edit_plugin(path: String, data: Dictionary) -> void:
		_edit_loadable(path, data, plugins)
	
	func _edit_loadable(path: String, data: Dictionary, list: Array) -> void:
		"""
		Find a loadable by path and replace the data in it via key-value pair
		"""
		var l = _find_matching_loadable("path", path, list)
		if typeof(l) == TYPE_INT:
			AppManager.logger.error(LOADABLE_NOT_FOUND_ERROR)
			return
		
		# If we are updating the path, make sure we aren't creating a duplicate
		if data.has("path"):
			var new_path: String = data["path"]
			# If the path is the same, then we are just updating in place
			if new_path != path:
				# Path already exists
				if _find_matching_loadable_count("path", new_path, list) > 0:
					AppManager.logger.error(LOADABLE_ALREADY_EXISTS_ERROR)
					return
		
		# TODO check to see if this actually changes anything
		for key in data.keys():
			l.set(key, data[key])
	
	func remove_template(path: String) -> void:
		_remove_loadable(path, templates)
	
	func remove_plugin(path: String) -> void:
		_remove_loadable(path, plugins)
	
	func _remove_loadable(path: String, list: Array) -> void:
		var l = _find_matching_loadable("path", path, list)
		if typeof(l) == TYPE_INT:
			AppManager.logger.error(LOADABLE_NOT_FOUND_ERROR)
			return
		
		list.erase(l)
	
	func find_template(path: String) -> Template:
		var l = _find_matching_loadable("path", path, templates)
		if typeof(l) == TYPE_INT:
			AppManager.logger.error(LOADABLE_NOT_FOUND_ERROR)
			return null
		
		return l
	
	func find_plugin(path: String) -> Template:
		var l = _find_matching_loadable("path", path, plugins)
		if typeof(l) == TYPE_INT:
			AppManager.logger.error(LOADABLE_NOT_FOUND_ERROR)
			return null
		
		return l
	
	func _find_matching_loadable(key: String, val, list: Array):
		"""
		Uses dynamic + duck typing
		Returns a value if something is found, otherwise returns FAILED
		"""
		for i in list:
			var v = i.get(key)
			if (v != null and v == val):
				return i
		return FAILED
	
	func _find_matching_loadable_count(key: String, val, list: Array) -> int:
		var r: int = 0
		
		for i in list:
			var v = i.get(key)
			if (v != null and v == val):
				r += 1
		
		return r
	
	# TODO this shouldn't need to be here but currently it kind of does
	func _determine_default_search_path() -> String:
		var output: Array = []
		match OS.get_name().to_lower():
			"windows":
# warning-ignore:return_value_discarded
				OS.execute("echo", ["%HOMEDRIVE%%HOMEPATH%"], true, output)
			"osx", "x11":
# warning-ignore:return_value_discarded
				OS.execute("echo", ["$HOME"], true, output)
		if output.size() == 1:
			return FileSystem.strip_drive(output[0].strip_edges())
		return "/"

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _init() -> void:
	if not OS.is_debug_build():
		_config_path = "user://"
	else:
		_config_path = FileSystem.strip_drive(ProjectSettings.globalize_path("res://export/"))
	
	load_config()
	
	finished_loading = true

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func config() -> ConfigData:
	# Just try to save whenever we access the config
	AppManager.should_save = true
	return _current_config

func config_path() -> String:
	return _config_path

func save_config() -> void:
	AppManager.logger.info("Saving config")
	
	var file := File.new()
	if file.open("%s%s" % [_config_path, CONFIG_NAME], File.WRITE) != OK:
		AppManager.logger.error(CONFIG_UNABLE_TO_WRITE_ERROR)
		return
	file.store_string(_current_config.get_as_json())
	file.close()
	
	AppManager.logger.info("Finished saving config")

func load_config() -> void:
	AppManager.logger.info("Loading config")
	
	_current_config = ConfigData.new()
	var file := File.new()
	
	if file.open("%s%s" % [_config_path, CONFIG_NAME], File.READ) != OK:
		AppManager.logger.info(CONFIG_UNABLE_TO_OPEN_ERROR)
		return
	
	if _current_config.load_from_json(file.get_as_text()) != OK:
		AppManager.logger.error(CONFIG_UNABLE_TO_READ_ERROR)
		return
	
	AppManager.logger.info("Finished loading config")
