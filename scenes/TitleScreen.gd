extends Control

func _on_Button_Play_pressed():
	# TODO: make this fancier
	MusicManager.stop_menu_music()
	get_tree().change_scene("res://scenes/Game.tscn")

func _on_Button_Credits_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")

func _on_Button_Quit_pressed():
	get_tree().quit()

func _ready() -> void:
	MusicManager.play_menu_music()
