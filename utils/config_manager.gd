class_name ConfigManager
extends Reference

const DEBOUNCE_TIME: float = 0.5
var should_save := false

var config_path: String # For switching between debug config and release config
var current_config: ConfigData

class ConfigData:
	
	var templates: Array = ["test/template"] # Folder paths
	var plugins: Array = ["test/plugin", "test/plugin1"] # Plugin paths
	
	# Config
	
	var show_full_file_paths := false
	
	func get_as_json() -> String:
		var result: Dictionary = {}

		for i in get_property_list():
			if not i.name in ["Reference", "script", "Script Variables"]:
				var i_value = get(i.name)

				result[i.name] = i_value

		return JSON.print(result)

	func load_from_json(json_string: String) -> void:
		"""
		Converts json string to a dictionary with the appropriate values
		"""
		var json_result = parse_json(json_string)

		if typeof(json_result) != TYPE_DICTIONARY:
			AppManager.logger.error("Invalid config data loaded")
			return

		for key in (json_result as Dictionary).keys():
			var data = json_result[key]
			
			# TODO probably need more advanced logic here

			set(key, data)

	func load_from_dict(json_dict: Dictionary) -> void:
		"""
		Since we are using the class as a struct, we can't just set the
		dict to a value
		"""
		for key in json_dict.keys():
			set(key, json_dict[key])

	func duplicate() -> ConfigData:
		var cd = ConfigData.new()
		for i in get_property_list():
			if not i.name in ["Reference", "script", "Script Variables"]:
				var i_value = get(i.name)

				cd.set(i.name, i_value)

		return cd

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _init() -> void:
	if not OS.is_debug_build():
		config_path = "user://"
	else:
		config_path = "res://export"

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################
