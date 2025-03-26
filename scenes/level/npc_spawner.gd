class_name NPCSpawner
extends Node2D

signal npc_scored(points, accuracy)

@export var level_data: LevelData
@export var spawn_offset: float = -100.0  # Spawn above screen

var npc_pools: Dictionary = {}
var active_npcs: Array[NPCBase] = []
var screen_width: float
var current_time: float = 0.0

func _ready() -> void:
	screen_width = get_viewport_rect().size.x
	initialize_object_pools()
	
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		rhythm_manager.beat.connect(_on_beat)

func _process(delta: float) -> void:
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		current_time = rhythm_manager.song_position
	else:
		current_time += delta
		
	check_spawn_npcs()
	process_active_npcs()

func initialize_object_pools() -> void:
	# This will be filled with actual NPC types during development
	var npc_types = {
		"oscillator": {
			"scene": preload("res://scenes/npcs/NPC_Oscillator.tscn"),
			"count": 20
		},
		"percussion": {
			"scene": preload("res://scenes/npcs/NPC_Percussion.tscn"),
			"count": 20
		}
	}
	
	# Create pools for each NPC type
	for type in npc_types:
		npc_pools[type] = []
		for i in range(npc_types[type]["count"]):
			var npc = npc_types[type]["scene"].instantiate()
			npc.deactivate()
			add_child(npc)
			npc_pools[type].append(npc)

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
	# We can use this for visual timing cues if needed
	pass