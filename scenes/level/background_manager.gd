class_name BackgroundManager
extends ParallaxBackground

@export var scroll_speed: float = 100.0
@export var bpm_sync: bool = true

var base_scroll_speed: float = 100.0

func _ready() -> void:
	# If we want to sync with BPM, we'll update on beat signals
	if bpm_sync and Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		rhythm_manager.beat.connect(_on_beat)

func _process(delta: float) -> void:
	# Only access RhythmManager if it exists
	if Engine.has_singleton("RhythmManager"):
		var rhythm_manager = Engine.get_singleton("RhythmManager")
		if not bpm_sync and rhythm_manager.playing:
			# Constant scrolling for non-BPM sync mode
			scroll_offset.y += scroll_speed * delta
	else:
		# Fallback for testing: constant scrolling
		scroll_offset.y += scroll_speed * delta

func set_bpm(new_bpm: float) -> void:
	if bpm_sync:
		# Adjust scroll speed based on BPM
		# A simple formula might be:
		scroll_speed = base_scroll_speed * (new_bpm / 120.0)

func _on_beat(beat_count: int) -> void:
	if not Engine.has_singleton("RhythmManager"):
		return
		
	var rhythm_manager = Engine.get_singleton("RhythmManager")
	if bpm_sync and rhythm_manager.playing:
		# Move the background by a fixed amount on each beat
		scroll_offset.y += (scroll_speed / rhythm_manager.bpm) * 60.0