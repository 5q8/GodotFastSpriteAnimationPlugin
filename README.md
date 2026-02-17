# Godot Fast Sprite Animation Plugin

A Godot editor tool that streamlines the creation of frame-based animations from sprite sheets.

You can also download it from the official Godot [Asset Library Page](https://godotengine.org/asset-library/asset/4790)

<img width="455" height="409" alt="image" src="https://github.com/user-attachments/assets/ee88f49c-8f13-428f-8737-6b146ca85f5e" />

## Features

- **Quick Animation Creation**: Generate animations directly from sprite sheet rows
- **Visual Preview**: See your sprite sheet texture in the editor
- **Flexible Configuration**: 
  - Select any row from your sprite sheet
  - Customize frame duration
  - Name animations easily
- **Automatic Setup**: Creates AnimationLibrary and keyframes automatically

## How to Use

1. **Select Your Sprite2D**: In the scene tree, click on your Sprite2D node, then click the "Select Sprite2D node" button
2. **Select Your AnimationPlayer**: In the scene tree, click on your AnimationPlayer node, then click the "Select AnimationPlayer node" button
3. **Configure Animation**:
   - **Select Row**: Choose which row of frames to animate
   - **Frame Duration**: Set how long each frame displays (in seconds)
   - **Animation Name**: Give your animation a name
4. **Create**: Click "Add Animation" to generate the animation

## Requirements

- Godot 4.6
- A Sprite2D with `hframes` and `vframes` properly configured (important)
- An AnimationPlayer node to receive the animation


