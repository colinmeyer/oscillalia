class_name NPCOscillator
extends NPCBase

@export var note_pitch: String = "C4"  # Musical note representation

func _ready() -> void:
	super._ready()
	npc_type = "oscillator"