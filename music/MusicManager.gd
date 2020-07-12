extends Node

const FADE_TIME : float = 0.8

onready var ingame_tracks = {
	"main": $InGame/Main,
	"power": $InGame/Power,
	"steering": $InGame/Steering,
	"radar": $InGame/Radar
}

onready var tween = $Tween

func switch_to_track(which_track : String) -> void:
	tween.stop_all()
	for track_name in ingame_tracks:
		var track = ingame_tracks[track_name]
		if track_name == which_track:
			tween.interpolate_property(track, "volume_db", track.volume_db, 0.0, FADE_TIME, Tween.TRANS_QUINT, Tween.EASE_OUT)
		else:
			tween.interpolate_property(track, "volume_db", track.volume_db, -60.0, FADE_TIME, Tween.TRANS_QUINT, Tween.EASE_IN)
	tween.start()

func stop_music_suddenly() -> void:
	for track_name in ingame_tracks:
		ingame_tracks[track_name].stop()

func start_music() -> void:
	for track_name in ingame_tracks:
		if track_name == "main":
			ingame_tracks[track_name].volume_db = 0.0
		else:
			ingame_tracks[track_name].volume_db = -60.0
		ingame_tracks[track_name].play()
