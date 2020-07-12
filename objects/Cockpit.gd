extends Control

signal go_to_radar
signal go_to_energy_system
signal go_to_radio
signal go_to_phone

onready var button_phone = $Button_Phone

func set_phone_active(active : bool) -> void:
	button_phone.disabled = !active

func _on_Button_Radar_pressed() -> void:
	emit_signal("go_to_radar")

func _on_Button_Energy_pressed() -> void:
	emit_signal("go_to_energy_system")

func _on_Button_Radio_pressed() -> void:
	emit_signal("go_to_radio")

func _on_Button_Phone_pressed() -> void:
	emit_signal("go_to_phone")
