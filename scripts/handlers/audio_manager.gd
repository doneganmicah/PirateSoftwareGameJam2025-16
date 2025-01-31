extends AudioStreamPlayer2D
@export var music_bus: String = "Music"
@onready var audio_player := AudioStreamPlayer.new()

var music_tracks: Dictionary = {}
var current_track: String = ""

func _init() -> void:
	add_track("TitleTheme", AudioTracks.TITLE_THEME)
	add_track("IntroSad", AudioTracks.INTRO)
	add_track("Finale", AudioTracks.FINALE)
	add_track("Good_init", AudioTracks.GOOD_INITIAL)
	add_track("Good_loop", AudioTracks.GOOD_LOOP)
	add_track("Bad_init", AudioTracks.BAD_INITIAL)
	add_track("Bad_loop", AudioTracks.BAD_LOOP)
	add_track("Neut_init", AudioTracks.NEUTRAL_INITIAL)
	add_track("Neut_loop", AudioTracks.NEUTRAL_LOOP)

func _ready() -> void:
	add_child(audio_player)
	audio_player.finished.connect(_on_music_finished)
	
func add_track(track_name: String, track: AudioStream) -> void:
	music_tracks[track_name] = track
	
func play_music(track_name: String, crossfade: float = 1.0) -> void:
	if current_track == track_name:
		return  # Already playing
		
	if track_name in music_tracks:
		current_track = track_name
		var new_track = music_tracks[track_name]
		
		if audio_player.playing:
			_crossfade_music(new_track, crossfade)
		else:
			audio_player.stream = new_track
			audio_player.play()
			
func _crossfade_music(new_track: AudioStream, duration: float) -> void:
	await get_tree().create_tween().tween_property(audio_player, "volume_db", -80, duration / 2).finished
	audio_player.stream = new_track
	audio_player.play()
	get_tree().create_tween().tween_property(audio_player, "volume_db", 0, duration / 2)
	
func stop_music(fade_out: float = 1.0) -> void:
	if audio_player.playing:
		await get_tree().create_tween().tween_property(audio_player, "volume_db", -80, fade_out).finished
		audio_player.stop()
		current_track = ""
		
func _on_music_finished() -> void:
	if(current_track == "Neut_init"):
		play_music("Neut_loop", 0)
	elif(current_track == "Bad_init"):
		play_music("Bad_loop", 0)
	elif(current_track == "Good_init"):
		play_music("Good_loop", 0)
		
	audio_player.play()  # Loop the current track
