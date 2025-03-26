class_name NPCBase
extends Area2D

@export var sound_to_play: AudioStream
@export var points_value: int = 100
@export var npc_type: String = "base"
@export var target_beat: float = 0.0

var speed: float = 200.0
var is_active: bool = false
var was_interacted: bool = false

func _ready() -> void:
	monitoring = false
	monitorable = true

func _process(delta: float) -> void:
	if is_active:
		position.y += speed * delta

func initialize(spawn_position: Vector2, beat: float) -> void:
	position = spawn_position
	target_beat = beat
	is_active = true
	was_interacted = false
	visible = true
	monitoring = false

func deactivate() -> void:
	is_active = false
	visible = false
	monitoring = false
	
func interact() -> void:
	if was_interacted:
		return
		
	was_interacted = true
	
	if Engine.has_singleton("AudioManager"):
		var audio_manager = Engine.get_singleton("AudioManager")
		audio_manager.play_sound(sound_to_play)
	
	# Visual feedback can be implemented here
	
	# Get timing accuracy
	var accuracy = "Miss"
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		accuracy = rhythm_manager.get_timing_accuracy(target_beat)
	
	# Calculate score based on accuracy
	var score = 0
	match accuracy:
		"Perfect":
			score = points_value
		"Great":
			score = int(points_value * 0.8)
		"Good":
			score = int(points_value * 0.5)
		"Miss":
			score = 0
	
	# Emit signal with score and accuracy
	# We'll implement this signal in specific NPC types