extends Node

const FADE_TIME : float = 0.8

onready var music_booth = $MusicBooth

func change_music(state : String) -> void:
	match state:
		"main":
			music_booth.play_song_on_bar("Main", FADE_TIME)
		"radar":
			music_booth.play_song_on_bar("Radar", FADE_TIME)
		"steering":
			music_booth.play_song_on_bar("Steering", FADE_TIME)

func stop_music_suddenly() -> void:
	music_booth.stop_song()

func start_music() -> void:
	music_booth.play_song("Main")
