extends Node

const ENV_VAR_NAME: String = "GODOT_ENV"
const ENVS: Dictionary = {
	"DEFAULT": "default",
	"TEST": "test"
}

onready var logger: Logger = load("res://utils/logger.gd").new()
onready var cm: ConfigManager = load("res://utils/config_manager.gd").new()
onready var sb: SignalBroadcaster = load("res://utils/signal_broadcaster.gd").new()

# Debounce
const DEBOUNCE_TIME: float = 5.0
var debounce_counter: float = 0.0
var should_save := false

var env: String = ENVS.DEFAULT

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
# warning-ignore:return_value_discarded
	self.connect("tree_exiting", self, "_on_tree_exiting")

	var system_env = OS.get_environment(ENV_VAR_NAME)
	if system_env:
		env = system_env

func _process(delta: float) -> void:
	if should_save:
		debounce_counter += delta
		if debounce_counter > DEBOUNCE_TIME:
			debounce_counter = 0.0
			should_save = false
			cm.save_config()

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_tree_exiting() -> void:
	if env != ENVS.TEST:
		should_save = false
		cm.save_config()
	
	logger.info("Exiting. おやすみ。")

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

func destroy_node(n: Node) -> void:
	n.queue_free()
