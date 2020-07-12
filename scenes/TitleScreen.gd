extends Control

onready var logo = $Logo
onready var buttons = $Buttons
onready var background = $Background
onready var tween = $Tween

var going_out : bool = false

func _on_Button_Play_pressed():
	if going_out:
		return
	going_out = true
	tween.interpolate_property(logo, "rect_position", logo.rect_position, Vector2(0, -180), 0.5, Tween.TRANS_BACK, Tween.EASE_IN)
	tween.interpolate_property(buttons, "rect_position", buttons.rect_position, buttons.rect_position + Vector2(0, 32), 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.interpolate_property(background, "modulate", background.modulate, Color.white, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")
	MusicManager.stop_menu_music()
	get_tree().change_scene("res://scenes/Game.tscn")

func _on_Button_Credits_pressed():
	if going_out:
		return
	get_tree().change_scene("res://scenes/Credits.tscn")

func _on_Button_Quit_pressed():
	if going_out:
		return
	get_tree().quit()

func _ready() -> void:
	MusicManager.play_menu_music()
