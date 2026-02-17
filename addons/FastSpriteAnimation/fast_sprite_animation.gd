@tool
extends EditorPlugin

var dock

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	dock = preload("res://addons/FastSpriteAnimation/interface.tscn").instantiate()
	dock.editor_interface = get_editor_interface()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BL, dock)


func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()
