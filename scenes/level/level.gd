class_name Level
extends Node2D

signal level_completed(score, max_combo)
signal level_failed

@export var level_data: LevelData

var player: Player
var npc_spawner: NPCSpawner
var background_manager: ParallaxBackground
var ui_layer: CanvasLayer
var score: int = 0
var max_combo: int = 0
var current_combo: int = 0
var game_state: String = "ready"  # ready, playing, paused, completed
var is_endless_mode: bool = false

func _ready() -> void:
	player = $Player
	npc_spawner = $NPCSpawner
	background_manager = $BackgroundManager
	ui_layer = $GameUI
	
	# Connect signals
	player.score_updated.connect(_on_score_updated)
	npc_spawner.npc_scored.connect(_on_score_updated)
	ui_layer.pause_requested.connect(pause_level)
	ui_layer.resume_requested.connect(resume_level)
	
	# Make this node findable by name for NPCs
	name = "GameLevel"
	
	# Check for endless mode
	if level_data == null:
		is_endless_mode = true
		print("Endless mode detected")
	
	setup_level()

func setup_level() -> void:
	# Reset score and combo
	score = 0
	max_combo = 0
	current_combo = 0
	
	if is_endless_mode:
		# Endless mode setup
		npc_spawner.level_data = null
		npc_spawner.continuous_spawning = true
		
		# Initialize UI with default name
		ui_layer.initialize("Endless Mode")
		print("Setting up endless mode")
	else:
		# Level data mode
		npc_spawner.level_data = level_data
		npc_spawner.continuous_spawning = false
		
		# Initialize UI with level name
		ui_layer.initialize(level_data.level_name)
	
	ui_layer.update_score(score)
	ui_layer.update_combo(current_combo)
	
	game_state = "ready"

func start_level() -> void:
	if game_state != "ready":
		return
		
	game_state = "playing"
	print("Starting level, endless mode:", is_endless_mode)
	
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		
		if is_endless_mode:
			# Start with internal clock at 120 BPM
			rhythm_manager.start_song(null, 120.0)
			print("Started rhythm manager in endless mode")
		elif level_data != null and level_data.song_file != null:
			# Start with actual audio file and BPM
			rhythm_manager.start_song(level_data.song_file, level_data.bpm)
	
	# If in endless mode, immediately start spawning NPCs
	if is_endless_mode:
		call_deferred("_force_spawn_npc")

func _force_spawn_npc() -> void:
	# This function sets up the spawning system in endless mode
	if npc_spawner and is_endless_mode:
		print("Starting continuous NPC spawning")
		
		# Just to be extra sure, set the flag for continuous spawning
		npc_spawner.continuous_spawning = true
		
		# Create a timer to spawn NPCs regularly
		var spawn_timer = Timer.new()
		spawn_timer.name = "SpawnTimer"
		add_child(spawn_timer)
		spawn_timer.wait_time = 1.0  # Spawn a new NPC every second
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
		spawn_timer.start()
		
		# Also spawn one NPC immediately to have something right away
		_on_spawn_timer_timeout()
			
		# Make sure RhythmManager is running for beat tracking
		if Engine.has_singleton("RhythmManager"):
			var rhythm_manager = Engine.get_singleton("RhythmManager")
			rhythm_manager.playing = true

# This gets called by the spawn timer to create a new NPC
func _on_spawn_timer_timeout() -> void:
	if not is_endless_mode or game_state != "playing":
		return
		
	# Determine random NPC properties
	var npc_types = ["oscillator", "percussion"]
	var npc_type = npc_types[randi() % npc_types.size()]
	
	# Choose random horizontal position (with some safe margins)
	var margin = 0.1
	var x_position = randf_range(margin, 1.0 - margin)
	
	# Set a target beat based on current position
	var target_beat = 4.0  # Default
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		target_beat = rhythm_manager.song_position_in_beats + 2.0  # 2 beats ahead
	
	# Create spawn data
	var spawn_data = {
		"type": npc_type,
		"position_x": x_position,
		"beat": target_beat
	}
	
	# Spawn the NPC
	npc_spawner.spawn_npc(spawn_data)
	
	# Log occasionally (not every spawn)
	if randf() < 0.1:  # 10% chance to log
		print("Spawned NPC: ", npc_type, " at position ", x_position, " for beat ", target_beat)

func pause_level() -> void:
	if game_state != "playing":
		return
		
	game_state = "paused"
	
	# Pause the spawn timer if in endless mode
	if is_endless_mode and has_node("SpawnTimer"):
		var timer = get_node("SpawnTimer")
		timer.paused = true
	
	# Additional pause logic here

func resume_level() -> void:
	if game_state != "paused":
		return
		
	game_state = "playing"
	
	# Resume the spawn timer if in endless mode
	if is_endless_mode and has_node("SpawnTimer"):
		var timer = get_node("SpawnTimer")
		timer.paused = false
	
	# Additional resume logic here

func complete_level() -> void:
	game_state = "completed"
	
	# Stop spawn timer if in endless mode
	if is_endless_mode and has_node("SpawnTimer"):
		var timer = get_node("SpawnTimer")
		timer.stop()
	
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		rhythm_manager.stop_song()
		
	level_completed.emit(score, max_combo)

func fail_level() -> void:
	game_state = "failed"
	
	# Stop spawn timer if in endless mode
	if is_endless_mode and has_node("SpawnTimer"):
		var timer = get_node("SpawnTimer")
		timer.stop()
	
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		rhythm_manager.stop_song()
		
	level_failed.emit()

func _on_score_updated(points: int, accuracy: String) -> void:
	score += points
	
	if points > 0:
		current_combo += 1
		if current_combo > max_combo:
			max_combo = current_combo
	else:
		current_combo = 0
	
	ui_layer.update_score(score)
	ui_layer.update_combo(current_combo)
	ui_layer.show_accuracy(accuracy)

func _process(delta: float) -> void:
	if game_state == "playing":
		var rhythm_manager = null
		if Engine.has_singleton("RhythmManager"):
			rhythm_manager = Engine.get_singleton("RhythmManager")
		
		# In endless mode, display debugging info
		if is_endless_mode and rhythm_manager and Engine.get_frames_drawn() % 120 == 0:
			print("Beat: ", rhythm_manager.song_position_in_beats, 
				  " NPCs: ", npc_spawner.active_npcs.size(),
				  " Next spawn: ", npc_spawner.next_spawn_beat)
		
		# Check if song is finished, but only for predefined levels
		if not is_endless_mode and rhythm_manager and level_data != null:
			if rhythm_manager.playing and rhythm_manager.song_position >= level_data.level_duration:
				complete_level()
		
	# Draw interaction zone line
	queue_redraw()

func _draw() -> void:
	# Draw a horizontal line to indicate the interaction zone
	if player:
		var line_position = player.position.y 
		var viewport_width = get_viewport_rect().size.x
		draw_line(
			Vector2(0, line_position),
			Vector2(viewport_width, line_position),
			Color(1.0, 1.0, 1.0, 0.2),
			3.0 # Line width
		)