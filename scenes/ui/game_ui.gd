class_name GameUI
extends CanvasLayer

@export var score_label: Label
@export var combo_label: Label
@export var accuracy_label: Label
@export var pause_button: Button
@export var level_name_label: Label

signal pause_requested
signal resume_requested

func _ready() -> void:
	if pause_button:
		pause_button.pressed.connect(_on_pause_button_pressed)
	
	if accuracy_label:
		accuracy_label.visible = false

func initialize(level_name: String) -> void:
	if level_name_label:
		level_name_label.text = level_name
	
	update_score(0)
	update_combo(0)

func update_score(score: int) -> void:
	if score_label:
		score_label.text = "Score: " + str(score)

func update_combo(combo: int) -> void:
	if combo_label:
		if combo > 0:
			combo_label.text = "Combo: " + str(combo)
			combo_label.visible = true
		else:
			combo_label.visible = false

func show_accuracy(accuracy: String) -> void:
	if not accuracy_label:
		return
		
	accuracy_label.text = accuracy
	
	# Set color based on accuracy
	match accuracy:
		"Perfect":
			accuracy_label.modulate = Color(1, 0.8, 0.2)  # Gold
		"Great":
			accuracy_label.modulate = Color(0.2, 0.8, 1)  # Cyan
		"Good":
			accuracy_label.modulate = Color(0.2, 1, 0.2)  # Green
		"Miss":
			accuracy_label.modulate = Color(1, 0.2, 0.2)  # Red
	
	accuracy_label.visible = true
	
	# Create a timer to hide the label after a short duration
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(func(): accuracy_label.visible = false)

func show_pause_menu() -> void:
	# Implement pause menu display
	pass

func hide_pause_menu() -> void:
	# Implement pause menu hiding
	pass

func _on_pause_button_pressed() -> void:
	pause_requested.emit()