extends Node

#this is the script for managing music. Autoload as Music

onready var music_booth = $MusicBooth

# Called when the node enters the scene tree for the first time.
func _ready():
	music_booth.play_song("Main")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Main_pressed():
	music_booth.play_song_on_bar("Main")


func _on_Rader_pressed():
	music_booth.play_song_on_bar("Radar")


func _on_Steering_pressed():
	music_booth.play_song_on_bar("Steering")
