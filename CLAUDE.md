# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Godot 4.4 psychological horror game project written in GDScript. The project uses the mobile rendering method and targets a viewport resolution of 1280x720.

## Development Commands

Since this is a Godot project, all development and testing is done through the Godot Editor:

- **Run the game**: Open project.godot in Godot Editor and press F5 or click the play button
- **Run main scene**: The main scene is set to Game.tscn (uid://c4qmoecwhl3v8)
- **Test specific scenes**: Use F6 to run the current scene in the editor

## Project Architecture

### Core Game Structure
- **Game.tscn**: Main game scene and entry point
- **Player/**: First-person character controller with mouse look and WASD movement
  - player.gd: CharacterBody3D with physics-based movement, jump mechanics, and fall detection
  - player.tscn: Player scene with Camera3D setup
- **Level/**: Game environment and terrain
  - Level.tscn: Main level scene with terrain mesh and materials
- **Interact/**: Interaction system for game objects
  - interactable.gd: Base class for interactable objects with customizable prompt messages
  - interact_ray.gd: RayCast3D system for detecting and displaying interaction prompts
- **Assets/**: 3D models, textures, and scene assets including forest environments, rocks, and train models

### Input Configuration
Custom input actions defined in project.godot:
- Movement: move_left (A), move_right (D), move_fwd (W), move_back (S)
- Jump: jump (Space)
- Menu: ui_cancel (Escape) - releases mouse capture

### Third-Party Addons
- **Proton Scatter**: Advanced object scattering plugin for procedural placement of environment objects
  - Located in addons/proton_scatter/
  - Includes modifiers for randomization, placement patterns, and terrain projection
  - Enabled in project settings

### Scene Structure
The project follows Godot's scene-based architecture:
- Main scenes are in the root directory (Game.tscn, Level.tscn)
- Component scenes are organized in feature folders (Player/, Interact/, Assets/)
- The player uses unique node names with % for scene references (e.g., %Camera3D)

### Rendering Configuration
- Renderer: Mobile rendering method for better performance
- Window stretch mode: viewport scaling
- Target platform: Mobile with feature flags for Godot 4.4