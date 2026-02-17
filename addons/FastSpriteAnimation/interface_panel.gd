@tool
extends Control

@onready var animation_player_selector_button : Button = $HBoxContainer/VBoxContainer/AnimationPlayerSelector
@onready var sprite2d_selector_button : Button = $HBoxContainer/VBoxContainer/Sprite2DSelector
@onready var sprite_sheet_preview : TextureRect = $HBoxContainer/SpriteSheetPreview
@onready var frame_size_x_label : Label = $HBoxContainer/VBoxContainer/FrameSizeX
@onready var frame_size_y_label : Label = $HBoxContainer/VBoxContainer/FrameSizeY
var editor_interface : EditorInterface

var assigned_sprite : Sprite2D
var assigned_animation_player : AnimationPlayer

func _ready():
	animation_player_selector_button.pressed.connect(_on_animation_player_selector_pressed)
	sprite2d_selector_button.pressed.connect(_on_sprite_2d_selector_pressed)


func _on_animation_player_selector_pressed() -> void:
	var selection = editor_interface.get_selection()
	var nodes = selection.get_selected_nodes()
	if nodes.is_empty():
		print("No node selected")
		return
	var node = nodes[0]
	if node is AnimationPlayer:
		assigned_animation_player = node
		animation_player_selector_button.text = "Selected node: " + node.name
		animation_player_selector_button.modulate = Color(0.0, 0.722, 0.0, 1.0)
	else:
		print("Selected node is not a AnimationPlayer")

func _on_sprite_2d_selector_pressed() -> void:
	var selection = editor_interface.get_selection()
	var nodes = selection.get_selected_nodes()
	if nodes.is_empty():
		print("No node selected")
		return
	var node = nodes[0]
	if node is Sprite2D and node.texture:
		assigned_sprite = node
		sprite2d_selector_button.text = "Selected node: " + node.name
		sprite2d_selector_button.modulate = Color(0.0, 0.722, 0.0, 1.0)
		_update_preview()
		
	else:
		print("Selected node is not a Sprite2D or node does not have a texture.")


func _update_preview():
	if not assigned_sprite or not assigned_sprite.texture:
		return
		
	var texture = assigned_sprite.texture
	var h_frames = assigned_sprite.hframes
	var v_frames = assigned_sprite.vframes
	var frame_width = texture.get_width() / h_frames
	var frame_height = texture.get_height() / v_frames
	
	sprite_sheet_preview.texture = assigned_sprite.texture
	frame_size_x_label.text = "Frame width: " + str(frame_width)
	frame_size_y_label.text = "Frame height: " + str(frame_height)
	
	
	
	
	
