extends Node

const ENV_VAR_NAME: String = "GODOT_ENV"
const ENVS: Dictionary = {
	"DEFAULT": "default",
	"TEST": "test"
}

onready var logger: Logger = load("res://utils/logger.gd").new()
onready var cm: ConfigManager = load("res://utils/config_manager.gd").new()

var env: String = ENVS.DEFAULT

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	self.connect("tree_exiting", self, "_on_tree_exiting")

	var system_env = OS.get_environment(ENV_VAR_NAME)
	if system_env:
		env = system_env
	
	cm.current_config = cm.ConfigData.new()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_tree_exiting() -> void:

	if env != ENVS.TEST:
		pass
	
	logger.info("Exiting. おやすみ。")

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func destroy_node(n: Node) -> void:
	n.queue_free()
