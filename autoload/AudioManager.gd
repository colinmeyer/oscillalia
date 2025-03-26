extends Node

var music_player: AudioStreamPlayer
var sound_pool: Array[AudioStreamPlayer] = []
var pool_size: int = 10
var current_pool_index: int = 0

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	
	# Create a pool of audio players for sound effects
	for i in range(pool_size):
		var player = AudioStreamPlayer.new()
		sound_pool.append(player)
		add_child(player)

func play_song(stream: AudioStream) -> void:
	music_player.stream = stream
	music_player.play()
	
func stop_song() -> void:
	music_player.stop()

func get_playback_position() -> float:
	return music_player.get_playback_position()

func play_sound(sound: AudioStream) -> void:
	if sound == null:
		return
		
	sound_pool[current_pool_index].stream = sound
	sound_pool[current_pool_index].play()
	
	current_pool_index = (current_pool_index + 1) % pool_size