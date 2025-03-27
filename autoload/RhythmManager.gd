extends Node

signal beat(beat_count)
signal measure_complete(measure_count)

var bpm: float = 120.0
var measures: int = 4

var song_position: float = 0.0
var song_position_in_beats: float = 0
var sec_per_beat: float = 60.0 / bpm
var last_beat: int = 0
var current_measure: int = 1
var time_since_start: float = 0.0

var playing: bool = false
var current_song: AudioStream
var use_internal_clock: bool = true  # Use internal clock when no audio is available

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if playing:
		# Get position from audio if available, otherwise use internal clock
		if current_song != null and not use_internal_clock:
			song_position = AudioManager.get_playback_position()
		else:
			# Use internal clock based on delta time
			time_since_start += delta
			song_position = time_since_start
		
		# Calculate beats
		song_position_in_beats = song_position / sec_per_beat
		
		if last_beat < int(song_position_in_beats):
			last_beat = int(song_position_in_beats)
			beat.emit(last_beat)
			
			if last_beat % measures == 0:
				current_measure = (last_beat / measures) + 1
				measure_complete.emit(current_measure)

func start_song(song: AudioStream = null, starting_bpm: float = 120.0) -> void:
	current_song = song
	bpm = starting_bpm
	sec_per_beat = 60.0 / bpm
	last_beat = 0
	current_measure = 1
	time_since_start = 0.0
	
	if song != null:
		AudioManager.play_song(song)
		use_internal_clock = false
	else:
		use_internal_clock = true
		
	playing = true

func stop_song() -> void:
	playing = false
	AudioManager.stop_song()

func get_timing_accuracy(target_beat: float) -> String:
	if not playing:
		return "Miss"
		
	var delta_beats = abs(song_position_in_beats - target_beat)
	
	if delta_beats < 0.05:
		return "Perfect"
	elif delta_beats < 0.1:
		return "Great"
	elif delta_beats < 0.2:
		return "Good"
	else:
		return "Miss"