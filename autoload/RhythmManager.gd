extends Node

signal beat(beat_count)
signal measure(measure_count)

var bpm: float = 120.0
var measures: int = 4

var song_position: float = 0.0
var song_position_in_beats: float = 0
var sec_per_beat: float = 60.0 / bpm
var last_beat: int = 0
var measure: int = 1

var playing: bool = false
var current_song: AudioStream

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if playing:
		song_position = AudioManager.get_playback_position()
		song_position_in_beats = song_position / sec_per_beat
		
		if last_beat < int(song_position_in_beats):
			last_beat = int(song_position_in_beats)
			beat.emit(last_beat)
			
			if last_beat % measures == 0:
				measure = (last_beat / measures) + 1
				measure.emit(measure)

func start_song(song: AudioStream, starting_bpm: float) -> void:
	current_song = song
	bpm = starting_bpm
	sec_per_beat = 60.0 / bpm
	last_beat = 0
	measure = 1
	AudioManager.play_song(song)
	playing = true

func stop_song() -> void:
	playing = false
	AudioManager.stop_song()

func get_timing_accuracy(target_beat: float) -> String:
	var delta_beats = abs(song_position_in_beats - target_beat)
	
	if delta_beats < 0.05:
		return "Perfect"
	elif delta_beats < 0.1:
		return "Great"
	elif delta_beats < 0.2:
		return "Good"
	else:
		return "Miss"