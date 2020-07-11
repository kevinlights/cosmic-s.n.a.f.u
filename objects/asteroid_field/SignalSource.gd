extends Node2D

onready var timer_change_frequency = $Timer_ChangeFrequency

var frequency : float = 0.0
var target_frequency : float = randf() * PI * 2.0

func _process(delta : float) -> void:
	frequency = lerp(frequency, target_frequency, delta / 2.0)
	#modulate.h = frequency

func _on_Timer_ChangeFrequency_timeout():
	target_frequency += (randf() - 0.5) * 0.25
	timer_change_frequency.start((randf() + 1.0) * 4.0)
