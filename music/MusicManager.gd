extends Node

#this is the script for managing music. Autoload as Music

onready var music_booth = $MusicBooth

export (float) var fade_time = 0.8

# Called when the node enters the scene tree for the first time.
func _ready():
	music_booth.play_song("Main")


func change_music(state):
	match state:
		"main":
			music_booth.play_song_on_bar("Main", fade_time)
		"radar":
			music_booth.play_song_on_bar("Radar", fade_time)
		"steering":
			music_booth.play_song_on_bar("Steering", fade_time)
		
		
		
func _on_Main_pressed():
	change_music("main")


func _on_Rader_pressed():
	change_music("radar")


func _on_Steering_pressed():
	change_music("radar")
