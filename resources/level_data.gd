class_name LevelData
extends Resource

@export var level_name: String = "Untitled Level"
@export var bpm: float = 120.0
@export var song_file: AudioStream
@export var background_scene: PackedScene
@export var npc_spawns: Array = []
@export var level_duration: float = 60.0  # Duration in seconds