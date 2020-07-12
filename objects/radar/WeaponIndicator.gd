extends Control

onready var label = $Label
onready var label_status = $Label_Status
onready var button_fire = $Button_Fire
onready var audio_hover = $Audio_Hover

var which_weapon : int

signal fire_weapon

func update_indicator(ready : bool, charge_amount : float) -> void:
	if ready:
		label_status.hide()
		button_fire.show()
	else:
		label_status.show()
		button_fire.hide()
		label_status.text = str("%03d" % int(charge_amount * 100)) + "%"

func set_label_text(text : String) -> void:
	label.text = text

func _on_Button_Fire_pressed() -> void:
	emit_signal("fire_weapon", which_weapon)

func _on_Button_Fire_mouse_entered():
	audio_hover.play()
