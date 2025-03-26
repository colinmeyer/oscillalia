class_name MainMenu
extends Control

@export var play_button: Button
@export var settings_button: Button
@export var quit_button: Button
@export var level_select_container: Control

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
		
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
		
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
		
	if level_select_container:
		level_select_container.visible = false

func _on_play_button_pressed() -> void:
	if level_select_container:
		level_select_container.visible = true
	else:
		start_level("res://resources/levels/level_1.tres")

func _on_settings_button_pressed() -> void:
	# Show settings menu
	pass

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func start_level(level_path: String) -> void:
	var level_resource = load(level_path)
	var game_scene = load("res://scenes/level/Level.tscn").instantiate()
	game_scene.level_data = level_resource
	
	# Replace the current scene with the game scene
	get_tree().root.add_child(game_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game_scene