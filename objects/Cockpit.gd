extends Control

signal go_to_radar
signal go_to_energy_system

func _on_Button_Radar_pressed() -> void:
	emit_signal("go_to_radar")

func _on_Button_Energy_pressed() -> void:
	emit_signal("go_to_energy_system")
