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
	
	if level_data:
		setup_level()

func setup_level() -> void:
	# Set up NPC spawner with level data
	npc_spawner.level_data = level_data
	
	# Initialize UI
	ui_layer.initialize(level_data.level_name)
	
	# Reset score and combo
	score = 0
	max_combo = 0
	current_combo = 0
	ui_layer.update_score(score)
	ui_layer.update_combo(current_combo)
	
	game_state = "ready"

func start_level() -> void:
	if game_state != "ready":
		return
		
	game_state = "playing"
	
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		rhythm_manager.start_song(level_data.song_file, level_data.bpm)
	
	# Start background scrolling
	# This will be handled by the background manager based on BPM

func pause_level() -> void:
	if game_state != "playing":
		return
		
	game_state = "paused"
	# Handle pause logic

func resume_level() -> void:
	if game_state != "paused":
		return
		
	game_state = "playing"
	# Handle resume logic

func complete_level() -> void:
	game_state = "completed"
	
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		rhythm_manager.stop_song()
		
	level_completed.emit(score, max_combo)

func fail_level() -> void:
	game_state = "failed"
	
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
	if game_state == "playing" and Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		# Check if song is finished
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