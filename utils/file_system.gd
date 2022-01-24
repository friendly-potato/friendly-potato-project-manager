class_name FileSystem
extends Reference

###############################################################################
# Builtin functions                                                           #
###############################################################################

###############################################################################
# Connections                                                                 #
###############################################################################

###############################################################################
# Private functions                                                           #
###############################################################################

###############################################################################
# Public functions                                                            #
###############################################################################

# Windows

static func rec_copy_windows(dir: String, path: String) -> void:
	# https://stackoverflow.com/questions/13314433/batch-file-to-copy-directories-recursively
	# warning-ignore:return_value_discarded
	OS.execute("CMD.exe", ["/c", "robocopy \"%s\" \"%s\" /e " % [dir, path]])

static func rec_rm_windows(path: String) -> void:
	# warning-ignore:return_value_discarded
	OS.execute("CMD.exe", ["/c", "rmdir \"%s\" /s /q" % path])
	AppManager.logger.trace("rmdir \"%s\" /s /q" % path)

static func strip_drive(path: String) -> String:
	# https://stackoverflow.com/questions/39372965/regex-to-strip-drive-letter
	var regex := RegEx.new()
	regex.compile("^[a-zA-Z]:")
	return regex.sub(path, "")

# Unix

static func rec_copy_linux(dir: String, path: String) -> void:
	# warning-ignore:return_value_discarded
	OS.execute("cp", ["-r", dir, path])

static func rec_rm_linux(path: String) -> void:
	# warning-ignore:return_value_discarded
	OS.execute("rm", ["-rf", path])
