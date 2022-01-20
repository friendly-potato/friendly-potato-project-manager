extends CanvasLayer

const ENV_PROJECT_NAME: String = "PROJECT_NAME"
const ENV_PROJECT_VERSION: String = "PROJECT_VERSION"

const APP_NAME: String = "FPPM"
const Version: Dictionary = {
	"MAJOR": 0,
	"MINOR": 0,
	"PATCH": 1
}

onready var normal_name_version: Label = $Control/AppNameContainer/NameVersion
onready var vertical_name_version: Label = $Control/VBoxContainer/NameVersion
var initial_app_name_label_length: int

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	var env_project_name: String = OS.get_environment(ENV_PROJECT_NAME)
	var env_version: String = OS.get_environment(ENV_PROJECT_VERSION)
	if env_version.length() != 0 and env_project_name.length() != 0:
		normal_name_version.text = "%s - %s" % [env_project_name, env_version]
	else:
		normal_name_version.text = "%s - %d.%d.%d" % [APP_NAME, Version.MAJOR, Version.MINOR, Version.PATCH]
	
	vertical_name_version.text = normal_name_version.text
	
	initial_app_name_label_length = normal_name_version.rect_size.x
	
	get_tree().root.connect("size_changed", self, "_on_size_changed")
	_on_size_changed()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_size_changed() -> void:
	var size: Vector2 = OS.window_size
	if size.x < initial_app_name_label_length * 3:
		normal_name_version.hide()
		vertical_name_version.show()
	else:
		normal_name_version.show()
		vertical_name_version.hide()

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################