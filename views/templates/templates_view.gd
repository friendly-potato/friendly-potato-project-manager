extends BaseView

###############################################################################
# Builtin functions                                                           #
###############################################################################

func _ready() -> void:
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Add.connect("pressed", self, "_on_add")
	$VBoxContainer/HBoxContainer/ButtonScroll/Buttons/Remove.connect("pressed", self, "_on_remove")

###############################################################################
# Connections                                                                 #
###############################################################################

func _on_add() -> void:
	var popup := create_dir_selector()
	popup.connect("dir_selected", self, "_on_dir_selected")
	
	add_child(popup)
	popup.popup_centered_ratio()

func _on_remove() -> void:
	if current_element == null:
		return
	
	current_element.queue_free()

###############################################################################
# Private functions                                                           #
###############################################################################

func _on_dir_selected(dir: String) -> void:
	print(dir)

###############################################################################
# Public functions                                                            #
###############################################################################
