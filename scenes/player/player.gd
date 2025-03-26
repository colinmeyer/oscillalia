class_name Player
extends CharacterBody2D

signal score_updated(points, accuracy)

@export var move_speed: float = 10.0
@export var screen_margin: float = 50.0

var target_position: Vector2
var screen_width: float
var interaction_area: Area2D

func _ready() -> void:
	interaction_area = $InteractionArea
	# Not using area-based detection anymore, but keeping the area for visual reference
	
	# Add to group so NPCs can find us
	add_to_group("player")
	
	screen_width = get_viewport_rect().size.x
	target_position = global_position

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		target_position.x = event.position.x
	elif event is InputEventScreenTouch and event.pressed:
		target_position.x = event.position.x

func _physics_process(delta: float) -> void:
	# Smoothly move towards target position
	var new_position = global_position.lerp(
		Vector2(target_position.x, global_position.y),
		move_speed * delta
	)
	
	# Clamp to screen bounds
	new_position.x = clamp(
		new_position.x, 
		screen_margin, 
		screen_width - screen_margin
	)
	
	global_position = new_position

func _draw() -> void:
	# Draw the interaction radius around the player (visual only)
	draw_circle(Vector2.ZERO, 80.0, Color(1.0, 1.0, 1.0, 0.2))
	
	# Reference the Visual node explicitly
	var visual = $Visual
	
func _process(_delta: float) -> void:
	# Constantly redraw to show the interaction radius
	queue_redraw()