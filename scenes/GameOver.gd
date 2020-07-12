extends Control

onready var label_quip = $Label_Quip
onready var tween = $Tween

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
	label_quip.text = quips[GameState.game_over_reason][rand_range(0, quips[GameState.game_over_reason].size())]
	tween.interpolate_property(self, "modulate", Color.black, Color.white, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.0)
	tween.start()

func _on_Button_Back_pressed():
	get_tree().change_scene("res://scenes/TitleScreen.tscn")
