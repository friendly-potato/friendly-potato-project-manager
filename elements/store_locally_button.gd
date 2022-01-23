class_name StoreLocallyButton
extends Button

enum ItemType {
	NONE = 0,
	TEMPLATE,
	PLUGIN
}

enum State {
	NONE = 0,
	START,
	CONFIRM_STORE,
	STORED,
	USE_REFERENCE,
	CONFIRM_UNSTORE
}

const STORE_LOCALLY: String = "Store locally"
const CONFIRM: String = "Confirm"
const STORED: String = "Stored"
const USE_REFERENCE: String = "Use reference"

var path: String

var item_type: int = ItemType.NONE
var state: int = State.NONE

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	rect_min_size.x = 110
	match state:
		State.START:
			text = STORE_LOCALLY
		State.STORED:
			text = STORED
		_:
			AppManager.logger.error("Unhandled state: %d" % state)
# warning-ignore:return_value_discarded
	connect("pressed", self, "_on_pressed")
# warning-ignore:return_value_discarded
	connect("mouse_exited", self, "_on_mouse_exited")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_mouse_exited() -> void:
	match state:
		State.CONFIRM_STORE:
			state = State.START
			text = STORE_LOCALLY
		State.CONFIRM_UNSTORE:
			state = State.STORED
			text = STORED

func _on_pressed() -> void:
	match state:
		State.START:
			state = State.CONFIRM_STORE
			text = CONFIRM
		State.CONFIRM_STORE:
			state = State.STORED
			text = STORED
			
			var new_path: String = _generate_user_data_path()
			match OS.get_name().to_lower():
				"windows":
					FileSystem.rec_copy_windows(path, new_path)
				"x11", "osx":
					FileSystem.rec_copy_linux(path, new_path)
			
			var payload: Dictionary = {
				"path": new_path,
				"is_local_copy": true
			}
			
			match item_type:
				ItemType.TEMPLATE:
					AppManager.cm.config().edit_template(path, payload)
				ItemType.PLUGIN:
					AppManager.cm.config().edit_plugin(path, payload)
			
			path = new_path
		State.STORED:
			state = State.USE_REFERENCE
			text = USE_REFERENCE
		State.USE_REFERENCE:
			state = State.CONFIRM_UNSTORE
			text = CONFIRM
		State.CONFIRM_UNSTORE:
			state = State.START
			text = STORE_LOCALLY
			
			match OS.get_name().to_lower():
				"windows":
					FileSystem.rec_rm_windows(_generate_user_data_path())
				"x11", "osx":
					FileSystem.rec_rm_linux(_generate_user_data_path())
			
			var payload: Dictionary = {
				"path": "",
				"is_local_copy": false
			}
			
			var new_path: String = ""
			
			match item_type:
				ItemType.TEMPLATE:
					var t := AppManager.cm.config().find_template(path)
					new_path = t.old_path
					payload["path"] = new_path
					AppManager.cm.config().edit_template(path, payload)
				ItemType.PLUGIN:
					var p := AppManager.cm.config().find_plugin(path)
					new_path = p.old_path
					payload["path"] = new_path
					AppManager.cm.config().edit_plugin(path, payload)
			
			path = new_path

###############################################################################
# Private functions                                                           #
###############################################################################

func _generate_user_data_path() -> String:
	return "%s%s" % [AppManager.cm.config_path(), path.get_file()]

###############################################################################
# Public functions                                                            #
###############################################################################
