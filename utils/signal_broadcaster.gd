class_name SignalBroadcaster
extends Reference

"""
Helper class for code-completing signals instead of relying on raw strings
"""

signal rescan_triggered()
func broadcast_rescan_triggered() -> void:
	emit_signal("rescan_triggered")
