extends Control

onready var label_quip = $Label_Quip
onready var label_time_value = $Grid_Stats/Label_Time_Value
onready var label_missiles_value = $Grid_Stats/Label_Missiles_Value
onready var label_asteroids_value = $Grid_Stats/Label_Asteroids_Value
onready var label_messages_value = $Grid_Stats/Label_Messages_Value
onready var tween = $Tween
onready var audio_ship_destroyed = $Audio_ShipDestroyed

const quips : Dictionary = {
	GameState.GameOverReason.SHIP_DESTROYED: [
		"That isn't going to buff out, you know.",
		"Your insurance isn't going to cover this.",
		"Protip: try to avoid getting smashed to bits by space rocks."
	],
	GameState.GameOverReason.TOO_MANY_WRONG_ANSWERS: [
		"Time can never mend...",
		"How unromantic."
	],
	GameState.GameOverReason.RESPONSE_TIMEOUT: [
		"Well, that's one way to get some peace and quiet.",
		"You really shouldn't leave 'em hanging like that, y'know?"
	]
}

func _ready() -> void:
	randomize()
	# Johnny wants big boom.
	if GameState.game_over_reason == GameState.GameOverReason.SHIP_DESTROYED:
		audio_ship_destroyed.play()
	# Fill out stats and snark
	var time_survived : int = int(floor(GameState.get_time_survived_msec() / 1000.0))
	var time_minutes : int = int(floor(time_survived / 60.0))
	var time_seconds : int = time_survived % 60
	label_time_value.text = str("%d:%d" % [time_minutes, time_seconds])
	label_missiles_value.text = str(GameState.missiles_fired)
	label_asteroids_value.text = str(GameState.asteroids_destroyed)
	label_messages_value.text = str(GameState.messages_sent)
	label_quip.text = quips[GameState.game_over_reason][rand_range(0, quips[GameState.game_over_reason].size())]
	# Fade in
	tween.interpolate_property(self, "modulate", Color.black, Color.white, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.0)
	tween.start()

func _on_Button_Back_pressed():
	get_tree().change_scene("res://scenes/TitleScreen.tscn")
