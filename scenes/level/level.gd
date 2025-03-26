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
	
	player.score_updated.connect(_on_score_updated)
	
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
	RhythmManager.start_song(level_data.song_file, level_data.bpm)
	
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
	RhythmManager.stop_song()
	level_completed.emit(score, max_combo)

func fail_level() -> void:
	game_state = "failed"
	RhythmManager.stop_song()
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
		# Check if song is finished
		if RhythmManager.playing and RhythmManager.song_position >= level_data.level_duration:
			complete_level()