class_name NPCSpawner
extends Node2D

signal npc_scored(points, accuracy)

@export var level_data: LevelData
@export var spawn_offset: float = -100.0  # Spawn above screen
@export var continuous_spawning: bool = true  # Enable automatic NPC generation
@export var spawn_rate_min: float = 1.0  # Minimum beats between spawns
@export var spawn_rate_max: float = 3.0  # Maximum beats between spawns
@export var spawn_count_min: int = 1  # Minimum NPCs to spawn at once
@export var spawn_count_max: int = 2  # Maximum NPCs to spawn at once

var npc_pools: Dictionary = {}
var active_npcs: Array[NPCBase] = []
var screen_width: float
var current_time: float = 0.0
var next_spawn_beat: float = 2.0  # First spawn at beat 2
var npc_types: Array = ["oscillator", "percussion"]
var last_beat: int = -1
var debug_mode: bool = true  # Enable debug prints

func _ready() -> void:
	screen_width = get_viewport_rect().size.x
	initialize_object_pools()
	
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		rhythm_manager.beat.connect(_on_beat)
		
	# Print debug status
	if debug_mode:
		print("NPCSpawner initialized")
		print("Continuous spawning: ", continuous_spawning)
		print("NPC Types: ", npc_types)

func _process(delta: float) -> void:
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		current_time = rhythm_manager.song_position
		
		# If there's no music playing but continuous spawning is enabled, 
		# generate NPCs at a steady rhythm even without music
		if continuous_spawning and not rhythm_manager.playing:
			rhythm_manager.start_song(null, 120.0)  # Start with internal clock
			if debug_mode:
				print("Starting rhythm with internal clock")
	else:
		current_time += delta
		
	# Check for predefined level data NPC spawns
	if level_data != null:
		check_spawn_npcs()
		
	# Always process active NPCs
	process_active_npcs()
	
	# Debug display
	if debug_mode and Engine.has_singleton("RhythmManager"):
		var rm = Engine.get_singleton("RhythmManager")
		if continuous_spawning and (Engine.get_frames_drawn() % 120 == 0): # Show only every 120 frames
			print("Beat: ", rm.song_position_in_beats, " Active NPCs: ", active_npcs.size())

func initialize_object_pools() -> void:
	# Create pools for each NPC type
	var configs = {
		"oscillator": {
			"scene": preload("res://scenes/npcs/NPC_Oscillator.tscn"),
			"count": 20
		},
		"percussion": {
			"scene": preload("res://scenes/npcs/NPC_Percussion.tscn"),
			"count": 20
		}
	}
	
	# First make sure the keys in this dictionary match our npc_types array
	if npc_types.size() != configs.keys().size():
		npc_types = configs.keys()
		print("Synchronized npc_types with config keys:", npc_types)
	
	for type in configs:
		npc_pools[type] = []
		for i in range(configs[type]["count"]):
			var npc = configs[type]["scene"].instantiate()
			npc.deactivate()
			add_child(npc)
			npc_pools[type].append(npc)
			
	if debug_mode:
		print("Created NPC pools: ", npc_pools.keys(), " with ", npc_pools["oscillator"].size(), " oscillators and ", npc_pools["percussion"].size(), " percussion")
		print("Continuous spawning setting:", continuous_spawning)

func check_spawn_npcs() -> void:
	if level_data == null:
		return
		
	# Check if any NPCs need to be spawned based on current time
	for spawn_data in level_data.npc_spawns:
		if not spawn_data.get("spawned", false) and is_time_to_spawn(spawn_data):
			spawn_npc(spawn_data)
			spawn_data["spawned"] = true

func is_time_to_spawn(spawn_data: Dictionary) -> bool:
	var spawn_beat = spawn_data["beat"]
	var current_beat = 0.0
	
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		current_beat = rhythm_manager.song_position_in_beats
	
	# Calculate how many beats ahead we need to spawn
	# This depends on speed and screen height
	var beats_ahead = 4.0  # Adjust based on testing
	
	return current_beat >= spawn_beat - beats_ahead

func spawn_npc(spawn_data: Dictionary) -> void:
	var npc_type = spawn_data["type"]
	var x_position = spawn_data["position_x"] * screen_width
	
	# Get an NPC from the pool
	if npc_pools.has(npc_type) and npc_pools[npc_type].size() > 0:
		for npc in npc_pools[npc_type]:
			if not npc.is_active:
				activate_npc(npc, spawn_data["beat"], Vector2(x_position, spawn_offset))
				if debug_mode:
					print("Spawned NPC: ", npc_type, " at position ", x_position)
				return
	
	print("Warning: No available NPC in pool for type: " + npc_type)

func activate_npc(npc: NPCBase, beat: float, spawn_position: Vector2) -> void:
	if not npc.is_connected("interaction_triggered", _on_npc_interaction_triggered):
		npc.interaction_triggered.connect(_on_npc_interaction_triggered)
	
	npc.initialize(spawn_position, beat)
	active_npcs.append(npc)
	
func _on_npc_interaction_triggered(points: int, accuracy: String) -> void:
	# Forward the signal to the level
	npc_scored.emit(points, accuracy)

func process_active_npcs() -> void:
	var npcs_to_remove = []
	
	for npc in active_npcs:
		if npc.global_position.y > get_viewport_rect().size.y + 100 or npc.was_interacted:
			npc.deactivate()
			npcs_to_remove.append(npc)
	
	# Remove deactivated NPCs from active list
	for npc in npcs_to_remove:
		active_npcs.erase(npc)

func _on_beat(beat_count: int) -> void:
	# Skip if it's the same beat (prevent duplicate processing)
	if beat_count == last_beat:
		return
		
	last_beat = beat_count
	
	# Check if it's time to spawn NPCs based on beat
	if continuous_spawning and beat_count >= next_spawn_beat:
		# Spawn 1-2 NPCs
		var spawn_count = randi_range(spawn_count_min, spawn_count_max)
		
		if debug_mode:
			print("Beat ", beat_count, ": Spawning ", spawn_count, " NPCs")
		
		for i in range(spawn_count):
			spawn_random_npc(beat_count)
		
		# Schedule next spawn
		next_spawn_beat = beat_count + randf_range(spawn_rate_min, spawn_rate_max)
		
func spawn_random_npc(current_beat: float) -> void:
	# Ensure we have NPC types defined
	if npc_types.size() == 0:
		npc_types = ["oscillator", "percussion"]
		if debug_mode:
			print("Reset NPC types to default")
	
	# Choose a random NPC type
	var npc_type = npc_types[randi() % npc_types.size()]
	
	# Generate random horizontal position
	var x_position = randf_range(0.1, 0.9) * screen_width
	
	# Define beat timing (slightly ahead to account for travel time)
	var target_beat = current_beat + 2.0  # Target beat is 2 beats ahead
	
	# Create spawn data
	var spawn_data = {
		"type": npc_type,
		"position_x": x_position / screen_width,
		"beat": target_beat
	}
	
	# Spawn the NPC
	spawn_npc(spawn_data)