Project Name: Oscillalia

Product Manager Hat: Vision, Strategy, Features
1. Product Vision:

To create an atmospheric and engaging mobile rhythm game where players feel immersed in a cosmic journey, using intuitive proximity-based interactions to co-create music with the game world. It should be easy to pick up but offer depth for rhythm game enthusiasts.

2. Target Audience:

Mobile gamers looking for unique, atmospheric experiences.

Rhythm game players seeking a novel interaction mechanic.

Casual gamers who enjoy music and simple, satisfying gameplay loops.

Players who appreciate generative or reactive audio experiences.

3. Unique Selling Proposition (USP):

Proximity-Based Rhythm: Unlike traditional tap/swipe rhythm games, interaction relies on positioning the character near NPCs at the right musical moment. This spatial element adds a unique layer of skill and visual feedback.

Atmospheric Journey: The "falling through space" theme, combined with evolving background visuals and dynamic sound design, creates a captivating and immersive experience.

Emergent Soundtrack: While based on a core track/BPM, the player's actions directly influence the melody and texture of the music, making each playthrough feel slightly different.

4. Core Gameplay Loop:

Select Level/Song: Choose a musical piece/challenge.

Fall & Observe: The character begins falling at a constant BPM-driven speed. The background scrolls upwards. NPCs appear from the bottom of the screen, so the user can plan their interactions by the time the NPC reaches their character.

Position & Interact: Player moves the character horizontally (and maybe slightly vertically?) to intercept or get close (or to avoid) to specific NPCs as they align with a rhythmic "hit zone" (implicit or explicit).

Generate Sound: Successful proximity interactions trigger sounds/musical notes corresponding to the NPC type, adding layers to the background music.

Score & Progress: Points are awarded based on timing accuracy (Perfect, Great, Good, Miss) and combos. (??)

Level Complete: Reach the end of the song/section, receive a score, potentially unlock rewards or the next level. Level gameplay is saved, so the resulting song may be viewed/listened to.

5. Key Features (MVP - Minimum Viable Product):

Core Movement: Smooth, responsive horizontal character control via touch (drag/swipe).

Falling & Scrolling: Constant downward player movement relative to the world; upward scrolling background synchronized with BPM.

NPC Types (Minimum 2-3):

Oscillator Sound NPC: Triggers a single melodic note on interaction. Different visual/color for different pitches?

Percussion NPC: Triggers a beat/rhythm element.

Proximity Interaction System: Detects player closeness to NPCs.

Rhythm/Timing System: Clear feedback on interaction timing relative to the music's beat/measure. Visual/audio cues are crucial.

Basic Scoring: Points for successful interactions, combo multiplier.

Sound Engine: Plays background music and triggered NPC sounds dynamically and in sync.

Level Structure: At least 3 distinct levels/songs with varying BPM and NPC patterns.

Basic UI: Start Menu, Level Select, In-Game HUD (Score, Combo), Results Screen.

6. Potential Future Enhancements (Post-MVP):

More NPC Types (Sustains, Effects, Obstacles to avoid).

Character Customization (Skins, Trails).

Advanced Scoring (Accuracy grades, leaderboards).

Special Abilities/Power-ups (Temporary larger interaction radius, score multipliers).

Dynamic Difficulty Adjustment.

Branching paths or choices within levels.

Story/Narrative elements.

Social Features (Sharing scores, challenges).

Monetization (Cosmetics, Ad removal, Song packs - design carefully to be non-intrusive).

7. Monetization Strategy (Initial Thoughts):

Free-to-play base game.

Rewarded Video Ads: Offer continues, small currency rewards, or temporary boosts in exchange for watching ads.

In-App Purchases (IAPs): Primarily cosmetic items (character skins, visual effects). Potentially sell additional song packs later. AVOID pay-to-win mechanics.

Game Architect Hat: Godot Implementation Strategy
1. Engine Choice:

Godot 4.x (Leverage performance improvements, rendering features, GDScript enhancements, better C# support if desired).

2. Core Scene Structure:

Main.tscn (Node or Node2D):

Root scene loader. Handles transitions between menus and gameplay.

Manages global state (e.g., player profile, settings).

Contains UI elements common across scenes (e.g., fade transitions).

GameUI.tscn (CanvasLayer):

Holds all primary UI elements (Score, Combo counter, Pause Button, Health/Energy if applicable). Instanced within Level.tscn.

Level.tscn (Node2D):

The main gameplay scene.

References the current song/level data.

Manages game state (Playing, Paused, GameOver).

Contains:

Player instance.

NPCSpawner node.

BackgroundManager node.

RhythmManager (or gets timing info from a global Singleton).

AudioManager node (or uses global Autoload).

GameUI instance.

Player.tscn (CharacterBody2D):

Handles player sprite/visuals (Sprite2D or AnimatedSprite2D).

Manages input detection (touchscreen).

Implements horizontal movement logic (move_and_slide or direct position manipulation). Clamped to screen bounds.

Contains an Area2D child node with a CollisionShape2D representing the interaction radius. This Area2D detects NPCs.

NPC_Base.tscn (Area2D):

Base scene for all NPCs.

Sprite2D / AnimatedSprite2D for visuals.

CollisionShape2D for interaction detection by the player.

Script (npc_base.gd) with export variables:

sound_to_play: AudioStream

points_value: int

npc_type: String (or Enum)

Movement properties (speed, pattern - if they move).

Handles basic downward movement (relative to the player's constant fall).

NPC_TypeA.tscn, NPC_TypeB.tscn, etc.:

Inherited scenes from NPC_Base.tscn.

Override visuals, sounds, points, and potentially specific interaction logic (e.g., a 'hold' NPC).

BackgroundManager.tscn (ParallaxBackground):

Contains ParallaxLayer nodes with Sprite2D or TextureRect children for different background layers (stars, nebulas, distant objects).

Script controls the scroll_offset based on time/BPM to create the upward scrolling effect simulating the player's fall.

3. Key Systems Implementation:

Rhythm & Timing:

Global RhythmManager (Autoload Singleton):

Loads song data (BPM, potentially beatmap info).

Maintains the current song time (AudioStreamPlayer.get_playback_position()).

Calculates current beat and measure.

Provides timing signals/functions for spawning and interaction checks.

Crucial for syncing audio, visuals, and gameplay logic.

Interaction Timing: When the Player's Area2D detects an NPC, the Player script (or the NPC itself) queries the RhythmManager to determine the timing accuracy based on the current song time vs. the NPC's designated beat time.

Player Movement & Input:

Use _input(event) in Player.gd to detect InputEventScreenDrag or InputEventScreenTouch.

Update the player's target horizontal position based on touch movement.

Smoothly interpolate the actual global_position.x towards the target position in _physics_process(delta).

Clamp global_position.x within screen boundaries.

The player's downward movement is simulated by everything else moving up. The player's global_position.y might remain relatively fixed on screen or have slight vertical control allowed.

NPC Spawning & Management:

NPCSpawner.gd:

Reads level data (e.g., a Resource file or JSON) containing NPC type, spawn time (in beats or seconds), and initial horizontal position for the entire song.

In _process(delta) or using Timer nodes synced to the beat, checks the RhythmManager's song time/beat.

When an NPC's spawn time is reached, instance the correct NPC_TypeX.tscn scene.

Crucial: Implement Object Pooling. Pre-instantiate NPCs and reuse them instead of constantly instancing/freeing. Have pools for each NPC type. When spawning, get an inactive NPC from the pool; when it goes off-screen or is interacted with, return it to the pool.

Spawn NPCs above the visible screen area. Their downward movement (relative to the player) will be handled by a script moving them based on the game's effective "fall speed" (derived from BPM or a constant value).

Interaction Logic:

Connect the area_entered signal of the Player's Area2D to a function in Player.gd.

When an NPC Area2D enters:

Identify the NPC type.

Check timing accuracy via RhythmManager.

Trigger appropriate feedback (visual effect, sound).

Send score information to the GameUI or a ScoreManager.

Possibly deactivate/queue for removal the interacted NPC (return to pool).

Consider an "interaction window" or "hit zone" (visualized or implicit) near the bottom or middle of the screen where interactions are valid. NPCs trigger sounds when the player is near them as they pass through this zone.

Audio Management:

AudioManager (Autoload Singleton or node in Level.tscn):

Holds the main AudioStreamPlayer for the background music.

Manages sound effect playback, possibly using multiple AudioStreamPlayer nodes for concurrent sounds or a dedicated system to play one-shot sounds (AudioServer.play() with bus management).

Use Audio Buses in Godot's mixer to control volumes (Music, SFX) and apply effects.

Ensure NPC sounds are triggered precisely based on interaction timing.

Background Scrolling:

In BackgroundManager.gd's _process(delta):

Calculate the distance scrolled this frame: scroll_speed * delta. The scroll_speed should be constant and potentially linked to the visual representation of the BPM.

Update ParallaxBackground.scroll_offset.y += distance_scrolled.

Ensure background textures are set to repeat or use sufficiently large textures/multiple sprites to avoid gaps.

4. Data Management:

Level Data: Use Godot's Custom Resources (*.tres). Create a LevelData resource script (level_data.gd extends Resource) with exported arrays/dictionaries defining:

bpm: float

song_file: AudioStream

npc_spawns: Array[Dictionary] (Each Dictionary: {"time": float, "position_x": float, "type": String/Enum})

Player Progress: Use FileAccess to save/load player data (unlocked levels, high scores, currency, owned cosmetics) to user:// directory. JSON is a good format.

5. Performance Considerations (Mobile):

Object Pooling: Absolutely essential for NPCs, effects, potentially even scrolling background elements if complex.

Draw Calls: Use Batching (enabled by default in Godot 4 Vulkan renderer) where possible. Consider texture atlases for sprites.

Shaders: Keep shaders simple initially. Avoid complex fullscreen shaders unless necessary and profile carefully.

Physics: Use Area2D for detection; avoid complex physics bodies if not needed.

GDScript: Profile code using Godot's built-in profiler. Optimize critical loops. Avoid heavy processing in _process if possible; use signals or timers where appropriate.

Resolution & Viewport Scaling: Use Godot's stretch modes (canvas_items or viewport) appropriate for different device aspect ratios. Test thoroughly.

Audio: Limit the number of simultaneously playing sounds if performance issues arise.

6. Technical Risks:

Audio Latency/Sync: Achieving perfect audio-visual-input sync on diverse Android/iOS hardware can be challenging. Use AudioServer.get_time_since_last_mix() or sync logic tightly with AudioStreamPlayer.get_playback_position(). Continuous testing on target devices is needed.

Performance Spikes: Spawning many NPCs or complex visual effects simultaneously could cause frame drops. Object pooling and optimization are key mitigations.

Input Responsiveness: Touch controls must feel immediate and accurate.

Scalability: Designing the level data format and spawner system to handle long/complex songs efficiently.

Next Steps (Initial Roadmap):

Prototype Core Mechanics (Sprint 1):

Set up basic project structure in Godot.

Implement player horizontal movement via touch.

Create the constant falling effect (upward scrolling background).

Implement basic NPC spawning (one type) at timed intervals.

Implement basic proximity detection (Player Area2D + NPC Area2D).

Trigger a placeholder sound on interaction.

Goal: Validate the core feel of movement and proximity interaction.

Integrate Rhythm & Scoring (Sprint 2):

Implement the RhythmManager to track song time/beats based on an AudioStreamPlayer.

Sync NPC spawning to beats.

Implement timing check for interactions (Perfect/Good/Miss).

Add basic scoring and combo display.

Goal: Validate the rhythm aspect and core gameplay loop.

Expand Content & Polish (Sprint 3+):

Add more NPC types with distinct sounds/visuals.

Create the first full level/song with varied patterns.

Refine UI/UX (menus, feedback).

Implement object pooling.

Improve visual effects and background art.

Start mobile testing and performance profiling.

