@tool
extends Control

@onready var animation_player_selector_button : Button = $HBoxContainer/VBoxContainer/AnimationPlayerSelector
@onready var sprite2d_selector_button : Button = $HBoxContainer/VBoxContainer/Sprite2DSelector
@onready var sprite_sheet_preview : TextureRect = $HBoxContainer/SpriteSheetPreview
@onready var frame_grid_overlay : Control = $HBoxContainer/SpriteSheetPreview/FrameGridOverlay
@onready var frame_size_x_label : Label = $HBoxContainer/VBoxContainer/FrameSizeX
@onready var frame_size_y_label : Label = $HBoxContainer/VBoxContainer/FrameSizeY
@onready var frame_duration_spinbox : SpinBox = $HBoxContainer/VBoxContainer/FrameDurationHBox/SpinBox
@onready var loop_checkbox : CheckBox = $HBoxContainer/VBoxContainer/LoopCheckBox
@onready var animation_name_text_edit : TextEdit = $HBoxContainer/VBoxContainer/AnimationName
@onready var add_animation_button : Button = $HBoxContainer/VBoxContainer/AddAnimation
@onready var clear_frames_button : Button = $HBoxContainer/VBoxContainer/ClearFramesButton
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

# Ordered list of selected frame indices (h_frames * row + col).
# Order matters — it's the order the frames will play in.
var selected_frames : Array[int] = []

const SELECTED_COLOR := Color(0.2, 0.8, 0.3, 0.45)
const GRID_LINE_COLOR := Color(1.0, 1.0, 1.0, 0.35)
const ORDER_LABEL_COLOR := Color(1.0, 1.0, 1.0, 1.0)


func _ready():
	loop_checkbox.button_pressed = false
	frame_grid_overlay.gui_input.connect(_on_frame_grid_overlay_gui_input)
	frame_grid_overlay.draw.connect(_on_frame_grid_overlay_draw)
	clear_frames_button.pressed.connect(_on_clear_frames_button_pressed)

	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.clip_text = false
	info_label.custom_minimum_size.x = 220
	info_label.size_flags_horizontal = Control.SIZE_FILL

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

	selected_frames.clear()
	_update_info_label()
	frame_grid_overlay.queue_redraw()


func _on_frame_grid_overlay_gui_input(event: InputEvent) -> void:
	if h_frames <= 0 or v_frames <= 0:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var overlay_size : Vector2 = frame_grid_overlay.size
		if overlay_size.x <= 0 or overlay_size.y <= 0:
			return

		var cell_w : float = overlay_size.x / h_frames
		var cell_h : float = overlay_size.y / v_frames

		var col : int = int(floor(event.position.x / cell_w))
		var row : int = int(floor(event.position.y / cell_h))
		col = clamp(col, 0, h_frames - 1)
		row = clamp(row, 0, v_frames - 1)

		var frame_index : int = row * h_frames + col

		var existing_pos := selected_frames.find(frame_index)
		if existing_pos != -1:
			# Clicking an already-selected frame removes it (toggle off).
			selected_frames.remove_at(existing_pos)
		else:
			# Shift+click inserts at the start, plain click appends to the end.
			if event.shift_pressed:
				selected_frames.push_front(frame_index)
			else:
				selected_frames.append(frame_index)

		_update_info_label()
		frame_grid_overlay.queue_redraw()


func _on_frame_grid_overlay_draw() -> void:
	if h_frames <= 0 or v_frames <= 0:
		return

	var overlay_size : Vector2 = frame_grid_overlay.size
	var cell_w : float = overlay_size.x / h_frames
	var cell_h : float = overlay_size.y / v_frames

	# Highlight selected cells + draw their play-order number.
	for order_i in selected_frames.size():
		var frame_index : int = selected_frames[order_i]
		var col : int = frame_index % h_frames
		var row : int = frame_index / h_frames
		var rect := Rect2(col * cell_w, row * cell_h, cell_w, cell_h)
		frame_grid_overlay.draw_rect(rect, SELECTED_COLOR, true)
		frame_grid_overlay.draw_string(
			ThemeDB.fallback_font,
			rect.position + Vector2(4, 14),
			str(order_i + 1),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			14,
			ORDER_LABEL_COLOR
		)

	# Grid lines.
	for col in range(h_frames + 1):
		var x := col * cell_w
		frame_grid_overlay.draw_line(Vector2(x, 0), Vector2(x, overlay_size.y), GRID_LINE_COLOR)
	for row in range(v_frames + 1):
		var y := row * cell_h
		frame_grid_overlay.draw_line(Vector2(0, y), Vector2(overlay_size.x, y), GRID_LINE_COLOR)


func _update_info_label() -> void:
	if selected_frames.is_empty():
		info_label.text = "No frames selected. Click cells in the preview to build the animation."
	else:
		var parts : Array[String] = []
		for f in selected_frames:
			parts.append(str(f))
		info_label.text = "Selected frames (in order): " + ", ".join(parts)


func _on_clear_frames_button_pressed() -> void:
	selected_frames.clear()
	_update_info_label()
	frame_grid_overlay.queue_redraw()


func _on_add_animation_pressed() -> void:
	if not assigned_sprite:
		print("No sprite selected!")
		return

	if not assigned_animation_player:
		print("No animation player selected!")
		return

	if selected_frames.is_empty():
		print("No frames selected! Click frames in the preview grid first.")
		return

	var frame_duration = frame_duration_spinbox.value
	var animation_name = animation_name_text_edit.text.strip_edges()

	if frame_duration <= 0.0 or animation_name == "":
		print("Frame duration cannot be 0 and animation name cannot be empty!")
		return

	var animation = Animation.new()

	animation.length = selected_frames.size() * frame_duration
	animation.loop_mode = Animation.LOOP_LINEAR if loop_checkbox.button_pressed else Animation.LOOP_NONE

	var track_index = animation.add_track(Animation.TYPE_VALUE)
	animation.value_track_set_update_mode(track_index, Animation.UPDATE_DISCRETE)

	# Path must be relative to the AnimationPlayer's root node, not the scene root.
	var anim_root = assigned_animation_player.get_node(assigned_animation_player.root_node)
	var relative_path = anim_root.get_path_to(assigned_sprite)
	animation.track_set_path(track_index, str(relative_path) + ":frame")

	for i in selected_frames.size():
		var time = i * frame_duration
		var frame_value = selected_frames[i]
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
	loop_checkbox.button_pressed = false
	selected_frames.clear()
	_update_info_label()
	frame_grid_overlay.queue_redraw()
