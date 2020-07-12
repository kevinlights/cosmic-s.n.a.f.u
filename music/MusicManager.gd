extends Node

const FADE_TIME : float = 0.8

const PITCHES : Array = [1.0, 1.05946, 1.12246, 1.18921, 1.25992, 1.33484, 1.41421, 1.49831]

onready var ingame_tracks = {
	"main": $InGame/Main,
	"power": $InGame/Power,
	"steering": $InGame/Steering,
	"radar": $InGame/Radar
}

onready var tween_track = $Tween_Track
onready var tween_tempo = $Tween_Tempo

var current_pitch : int = 0

func change_pitch(which_pitch : int) -> void:
	tween_tempo.stop_all()
	for track_name in ingame_tracks:
		var track = ingame_tracks[track_name]
		tween_tempo.interpolate_property(track, "pitch_scale", track.pitch_scale, PITCHES[which_pitch], 0.2, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween_tempo.start()

func increase_pitch() -> void:
	current_pitch += 1
	change_pitch(current_pitch)

func switch_to_track(which_track : String) -> void:
	tween_track.stop_all()
	for track_name in ingame_tracks:
		var track = ingame_tracks[track_name]
		if track_name == which_track:
			tween_track.interpolate_property(track, "volume_db", track.volume_db, 0.0, FADE_TIME, Tween.TRANS_QUINT, Tween.EASE_OUT)
		else:
			tween_track.interpolate_property(track, "volume_db", track.volume_db, -60.0, FADE_TIME, Tween.TRANS_QUINT, Tween.EASE_IN)
	tween_track.start()

func stop_music_suddenly() -> void:
	for track_name in ingame_tracks:
		ingame_tracks[track_name].stop()

func start_music() -> void:
	for track_name in ingame_tracks:
		if track_name == "main":
			ingame_tracks[track_name].volume_db = 0.0
		else:
			ingame_tracks[track_name].volume_db = -60.0
		ingame_tracks[track_name].pitch_scale = 1.0
		ingame_tracks[track_name].play()
