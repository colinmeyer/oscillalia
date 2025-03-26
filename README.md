# Oscillalia

A rhythm game where players feel immersed in a cosmic journey, using intuitive proximity-based interactions to co-create music with the game world.

## Project Structure

### Autoloads (Singletons)
- `RhythmManager.gd`: Manages timing, beats, and musical synchronization
- `AudioManager.gd`: Handles audio playback for music and sound effects

### Resources
- `level_data.gd`: Resource class for storing level/song data

### Scenes
- **Level**: Main gameplay scenes
  - `level.gd`: Main level controller
  - `background_manager.gd`: Controls parallax scrolling background
  - `npc_spawner.gd`: Manages NPC spawning and pooling

- **Player**:
  - `player.gd`: Player character with touch controls

- **NPCs**:
  - `npc_base.gd`: Base class for all NPCs
  - `npc_oscillator.gd`: Melodic note NPC
  - `npc_percussion.gd`: Rhythm element NPC

- **UI**:
  - `main_menu.gd`: Main menu screen
  - `game_ui.gd`: In-game UI elements

### Assets
- **audio**: Game music and sound effects
- **fonts**: UI fonts
- **sprites**: Game graphics
  - backgrounds: Parallax background elements
  - npcs: NPC sprite assets
  - player: Player character sprites

## Building and Running

1. Open the project in Godot 4.x
2. Run the main scene
3. If you're interested in contributing, see CONTRIBUTING.md

## License

[Insert license information here]