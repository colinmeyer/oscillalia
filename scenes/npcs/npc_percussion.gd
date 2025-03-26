class_name NPCPercussion
extends NPCBase

@export var percussion_type: String = "kick"  # Type of percussion sound

func _ready() -> void:
	super._ready()
	npc_type = "percussion"