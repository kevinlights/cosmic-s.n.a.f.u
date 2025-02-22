extends Control

const SIGNAL_THRESHOLD : float = 0.3

onready var waveform = $Waveform
onready var slider_angle = $RadioSlider_Angle
onready var slider_frequency = $RadioSlider_Frequency
onready var label_status = $Label_Status

signal back_from_radio

var game

func set_signal_strength(value : float) -> void:
	waveform.signal_strength = value
	if value >= SIGNAL_THRESHOLD:
		label_status.text = "SIGNAL OK"
	else:
		label_status.text = "SIGNAL WEAK"

func set_active(active : bool) -> void:
	slider_angle.active = active
	slider_frequency.active = active

func _on_RadioSlider_Angle_value_changed(value : float) -> void:
	game.radio_angle = value

func _on_RadioSlider_Frequency_value_changed(value : float) -> void:
	game.radio_frequency = value

func _on_Button_Back_pressed():
	emit_signal("back_from_radio")
