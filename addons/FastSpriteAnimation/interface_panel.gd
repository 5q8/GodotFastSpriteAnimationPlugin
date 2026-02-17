@tool
extends Control

@onready var animation_player_selector_button : Button = $HBoxContainer/VBoxContainer/AnimationPlayerSelector
@onready var sprite2d_selector_button : Button = $HBoxContainer/VBoxContainer/Sprite2DSelector
@onready var sprite_sheet_preview : TextureRect = $HBoxContainer/SpriteSheetPreview
@onready var frame_size_x_label : Label = $HBoxContainer/VBoxContainer/FrameSizeX
@onready var frame_size_y_label : Label = $HBoxContainer/VBoxContainer/FrameSizeY
@onready var frame_duration_spinbox : SpinBox = $HBoxContainer/VBoxContainer/FrameDurationHBox/SpinBox
@onready var select_row_spinbox : SpinBox = $HBoxContainer/VBoxContainer/SelectRowHBox/SpinBox
@onready var animation_name_text_edit : TextEdit = $HBoxContainer/VBoxContainer/AnimationName
@onready var add_animation_button : Button = $HBoxContainer/VBoxContainer/AddAnimation
@onready var info_label : Label = $HBoxContainer/VBoxContainer/InfoLabel
var editor_interface : EditorInterface

var assigned_sprite : Sprite2D
var assigned_animation_player : AnimationPlayer
var assigned_sprite_path : NodePath

var texture : Texture
var h_frames : int
var v_frames : int
var frame_width : int
var frame_height : int



func _ready():
	pass
	

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
		assigned_sprite_path = node.get_path()
		sprite2d_selector_button.text = "Selected node: " + node.name
		sprite2d_selector_button.modulate = Color(0.0, 0.722, 0.0, 1.0)
		_update_sprite2d()
		
	else:
		print("Selected node is not a Sprite2D or node does not have a texture.")


func _update_sprite2d():
	if not assigned_sprite or not assigned_sprite.texture:
		return
		
	texture = assigned_sprite.texture
	h_frames = assigned_sprite.hframes
	v_frames = assigned_sprite.vframes
	frame_width = texture.get_width() / h_frames
	frame_height = texture.get_height() / v_frames
	
	sprite_sheet_preview.texture = assigned_sprite.texture
	frame_size_x_label.text = "Frame width: " + str(frame_width)
	frame_size_y_label.text = "Frame height: " + str(frame_height)
	
	select_row_spinbox.max_value = v_frames - 1

func _on_add_animation_pressed() -> void:
	if not assigned_sprite:
		print("No sprite selected!")
		return
	
	if not assigned_animation_player:
		print("No animation player selected!")
		return
	
	var frame_duration = frame_duration_spinbox.value
	var animation_row = select_row_spinbox.value
	var animation_name = animation_name_text_edit.text.strip_edges()
	var first_frame = animation_row * h_frames
	var total_frames = h_frames
	
	if frame_duration <= 0.0 or animation_name == "":
		print("Frame duration cannot be 0 and animation name cannot be empty!")
		return
	
	var animation = Animation.new()
	
	animation.length = total_frames * frame_duration
	animation.loop_mode = Animation.LOOP_LINEAR
	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)
	animation.track_set_path(track_index, str(assigned_sprite_path) + ":frame")
	
	for i in total_frames:
		var time = i * frame_duration
		var frame_value = first_frame + i
		animation.track_insert_key(track_index, time, frame_value)

	var library : AnimationLibrary
	if assigned_animation_player.has_animation_library(""):
		library = assigned_animation_player.get_animation_library("")
	else:
		library = AnimationLibrary.new()
		assigned_animation_player.add_animation_library("", library)
	library.add_animation(animation_name, animation)

	print("Animation created:", animation_name)


func _on_clear_button_pressed() -> void:
	sprite2d_selector_button.text = "Select Sprite2D Node"
	animation_player_selector_button.text = "Select AnimationPlayer Node"
	animation_player_selector_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	sprite2d_selector_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	assigned_sprite = null
	assigned_animation_player = null
	texture = null
	sprite_sheet_preview.texture = null
	assigned_sprite_path = ""
	h_frames = 0
	v_frames = 0
	frame_width = 0
	frame_height = 0
	frame_size_x_label.text = "Frame width: "
	frame_size_y_label.text = "Frame height: "
