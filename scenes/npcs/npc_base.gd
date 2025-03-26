class_name NPCBase
extends Area2D

signal interaction_triggered(points, accuracy)

@export var sound_to_play: AudioStream
@export var points_value: int = 100
@export var npc_type: String = "base"
@export var target_beat: float = 0.0
@export var interaction_radius: float = 80.0  # Radius for proximity detection
@export var interaction_zone_y: float = 960.0  # Y position of the interaction zone

var speed: float = 200.0
var is_active: bool = false
var was_interacted: bool = false
var player_ref = null  # Removed type annotation
var in_interaction_zone: bool = false

func _ready() -> void:
	monitoring = false
	monitorable = true
	
	# Try to find the player in the scene
	find_player()

func _process(delta: float) -> void:
	if is_active:
		position.y += speed * delta
		
		# Check if NPC is in the interaction zone
		in_interaction_zone = abs(position.y - interaction_zone_y) < 50.0
		
		# Check proximity to player when in interaction zone
		if in_interaction_zone and player_ref != null and not was_interacted:
			# Cast to safe distance calculation
			var player_position = player_ref.global_position
			var distance = global_position.distance_to(player_position)
			
			# If player is within interaction radius, trigger interaction
			if distance <= interaction_radius:
				interact()
				
				# Show visual feedback
				modulate = Color(1.5, 1.5, 1.5, 1.0)  # Highlight to show interaction

func find_player() -> void:
	# Look for the GameLevel node by name
	var node = get_tree().get_first_node_in_group("player") 
	if node:
		player_ref = node
	else:
		# Fallback: try to find level by name and then its player child
		var level = get_tree().get_root().find_child("GameLevel", true, false)
		if level and level.has_node("Player"):
			player_ref = level.get_node("Player")

func initialize(spawn_position: Vector2, beat: float) -> void:
	position = spawn_position
	target_beat = beat
	is_active = true
	was_interacted = false
	visible = true
	monitoring = false
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# Try to find the player if we don't have a reference yet
	if player_ref == null:
		find_player()

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
	
	# Visual feedback is now in _process
	
	# Get timing accuracy
	var accuracy = "Miss"
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		accuracy = rhythm_manager.get_timing_accuracy(target_beat)
	
	# Calculate score based on accuracy and proximity
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
	interaction_triggered.emit(score, accuracy)
	
	# Create visual feedback - pulse effect
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.1)
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.5), 0.3)