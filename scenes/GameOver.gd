extends Control

onready var label_quip = $Label_Quip
onready var tween = $Tween

const quips : Array = [
	"That isn't going to buff out, you know.",
	"Your insurance isn't going to cover this.",
	"Protip: try to avoid getting smashed to bits by space rocks."
]

func _ready() -> void:
	randomize()
	label_quip.text = quips[rand_range(0, quips.size())]
	tween.interpolate_property(self, "modulate", Color.black, Color.white, 2.0, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.0)
	tween.start()

