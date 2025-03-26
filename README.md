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

### Requirements
- Godot Engine 4.x (4.4+ recommended)
- For mobile development: Android SDK or Xcode for iOS

### Opening the Project
1. Open Godot Engine
2. Click "Import" and select the project.godot file
3. Wait for Godot to import all resources

### Running the Game
1. After opening the project, locate `res://scenes/Main.tscn` in the FileSystem panel
2. Double-click to open this scene if it's not already open
3. Click the "Play" button in the top-right corner or press F5 to run the game
4. The game should start at the main menu
   - Click "Play" to start the game
   - Use mouse drag (or touch on mobile) to move the player character horizontally
   - The objective is to position your character near NPCs as they reach the interaction zone

### Game Controls
- **Mouse/Touch**: Click and drag horizontally to move the player character
- **Interaction**: Move close to NPCs as they arrive at your position to trigger sounds
- **Timing**: Perfect timing yields more points (Perfect, Great, Good, Miss)
- **Menu**: Click the pause button to pause the game
- **Exit**: Press Escape key to quit (desktop) or use the back button (mobile)

### Debug Features
- Press F8 during gameplay to skip to the next level (developer mode only)
- Press F1 to toggle performance statistics

For mobile testing:
1. Go to Project → Export
2. Select Android or iOS
3. Configure your export settings and SDK paths
4. Click "Export Project" and save the APK/IPA file
5. Install on your device for testing

### Development Commands
Run these commands from the project directory:

```bash
# Validate project files
godot --headless --script test_script.gd

# Export the project (creates a packaged build)
godot --headless --export-pack "Android" oscillalia.zip

# Build for specific platforms (requires export templates)
godot --headless --export "Android" oscillalia.apk
```

### Adding Audio Files
The project requires audio files to be placed in:
- Music tracks: `assets/audio/music/`  
- Sound effects: `assets/audio/sfx/`

To add your own audio:
1. Place audio files (OGG or WAV recommended) in the appropriate directories
2. Godot will automatically import them
3. To use a music track in a level:
   - Open the Level Editor scene
   - Select the level_data resource
   - In the Inspector, assign your music track to the "Song File" property
4. To use sound effects for NPCs:
   - Open the NPC scene you want to modify
   - In the Inspector, assign your sound effect to the "Sound To Play" property

For testing purposes, if you don't have audio files, the game will still run without them, but there will be no sound. You might see error messages in the console related to missing audio resources - these can be safely ignored during initial testing.

## Testing

The project includes a test script (`test_script.gd`) that validates critical components:
- Scene loading validation
- Resource availability
- Script compilation

Run the test with:
```bash
godot --headless --script test_script.gd
```

## License

MIT License - See LICENSE file for details

## Overview

Oscillalia is an atmospheric mobile rhythm game concept built using the Godot Engine. Players guide a character falling through a stylized cosmic environment at a constant rate synchronized to the music's BPM. Unlike traditional rhythm games relying on taps or swipes on static notes, interaction in Oscillalia is based on **spatial proximity**. Players maneuver their character horizontally to get close to various Non-Player Characters (NPCs) as they pass through an interaction zone, triggering musical sounds that layer onto the background track.

The core experience aims to be immersive, meditative, and musically rewarding, blending simple controls with a unique rhythmic challenge.

## Core Gameplay Concept

1.  **Constant Fall:** The player character "falls" downwards at a steady speed dictated by the level's BPM. The background scrolls upwards to simulate this movement.
2.  **NPC Observation:** Various types of NPCs appear from below the screen, moving upwards towards the player.
3.  **Proximity Interaction:** The player moves their character horizontally (via touch input) to position it near specific NPCs.
4.  **Rhythmic Triggering:** When the player is close enough to an NPC as it passes through a rhythmic "hit zone" (aligned with the music's beat), the NPC triggers a specific sound (melodic note, percussive hit, etc.).
5.  **Emergent Soundtrack:** Successful interactions add layers to the existing background music, allowing the player to co-create the soundscape.
6.  **Scoring:** Points are awarded based on the timing accuracy of interactions (e.g., Perfect, Great, Good, Miss), with combos for consecutive successful interactions.

## Key Features (Targeting MVP)

*   **Intuitive Touch Controls:** Simple horizontal drag/swipe controls for character movement.
*   **BPM-Synced World:** Player fall speed, background scrolling, and NPC movement tied to the music's tempo.
*   **Proximity-Based Interaction System:** Detects player closeness to NPCs for triggering sounds.
*   **Core NPC Types:** At least 2-3 distinct NPC types with unique sounds and visuals (e.g., melody notes, percussion).
*   **Rhythm & Timing Feedback:** Clear visual and audio cues for interaction timing and accuracy.
*   **Dynamic Audio Engine:** Plays background track and layers triggered NPC sounds seamlessly and in sync.
*   **Basic Scoring & Combo System:** Provides immediate feedback on player performance.
*   **Level Structure:** Initial set of distinct levels/songs.
*   **Essential UI:** Main Menu, Level Select, In-Game HUD (Score, Combo), Results Screen.

## Target Audience

*   Mobile gamers seeking unique, atmospheric experiences.
*   Rhythm game players interested in novel interaction mechanics.
*   Casual gamers who enjoy music and satisfying gameplay loops.

## Unique Selling Proposition (USP)

*   **Spatial Rhythm:** Interaction relies on positioning, not just tapping.
*   **Atmospheric Journey:** Immersive visuals and sound design create a captivating "falling through space" theme.
*   **Generative Audio:** Player actions directly influence the musical composition in real-time.

## Technology Stack

*   **Engine:** Godot Engine (v4.x recommended)
*   **Primary Language:** GDScript
*   **Platform:** Mobile (iOS & Android)

## Project Status & Initial Roadmap

**Status:** Planning & Initial Architecture Phase.

**High-Level Roadmap:**

1.  **Sprint 1: Core Mechanics Prototype**
    *   Focus: Implement player movement, falling simulation (scrolling), basic NPC spawning, and proximity detection triggering a placeholder sound.
    *   Goal: Validate the core feel of movement and interaction.
2.  **Sprint 2: Rhythm & Scoring Integration**
    *   Focus: Implement `RhythmManager` for audio sync, tie spawning and interaction checks to the beat, add basic scoring/combo logic.
    *   Goal: Validate the rhythm gameplay loop and timing mechanics.
3.  **Sprint 3+: Content Expansion & Polish**
    *   Focus: Add more NPC types, create initial levels, refine UI/UX, implement object pooling, improve visuals/audio feedback, begin mobile testing and optimization.
    *   Goal: Build out the MVP features into a playable experience.

---

This README provides a snapshot of the game's vision, mechanics, and development plan. Further details on architecture and implementation strategies are documented separately.

