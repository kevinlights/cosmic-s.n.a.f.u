extends Control

const ComputerFont = preload("res://fonts/computer.tres")
const COLOUR_DIM : Color = Color("687f8a")
const SHIELD_STRINGS : Array = ["FORE", "AFT", "PORT", "STRB"]
const STATUS_STRINGS : Array = ["  OK", " OFF", "CHRG"]

signal shield_toggled

onready var texture_shields : Array = [
	$Texture_Shield_Fore,
	$Texture_Shield_Aft,
	$Texture_Shield_Port,
	$Texture_Shield_Starboard
]

var game

func _draw() -> void:
	for i in range(0, SHIELD_STRINGS.size()):
		draw_string(ComputerFont, Vector2(-8, 72 + (i * 8)), SHIELD_STRINGS[i], COLOUR_DIM)
		if game.shield_state[i] != 2: # Not charing
			draw_string(ComputerFont, Vector2(32, 72 + (i * 8)), STATUS_STRINGS[game.shield_state[i]], Color.white)
		else:
			var recharge_status : String = str("%03d" % int(game.shield_recharge_rate[i] * 100)) + "%"
			draw_string(ComputerFont, Vector2(32, 72 + (i * 8)), recharge_status, Color.white)
	draw_string(ComputerFont, Vector2(-8, 112), "PWR DRAW", COLOUR_DIM)
	draw_string(ComputerFont, Vector2(-8, 120), str(game.get_shields_power_drain()) + "KW", Color.white)

func update_shield_indicator(which : int, up : bool) -> void:
	texture_shields[which].visible = up

func _on_Button_Shield_Fore_pressed() -> void:
	emit_signal("shield_toggled", 0)

func _on_Button_Shield_Aft_pressed() -> void:
	emit_signal("shield_toggled", 1)

func _on_Button_Shield_Port_pressed() -> void:
	emit_signal("shield_toggled", 2)

func _on_Button_Shield_Starboard_pressed() -> void:
	emit_signal("shield_toggled", 3)

func _on_Button_Shield_Fore_mouse_entered():
	texture_shields[0].modulate = Color.white

func _on_Button_Shield_Fore_mouse_exited():
	texture_shields[0].modulate = COLOUR_DIM

func _on_Button_Shield_Aft_mouse_entered():
	texture_shields[1].modulate = Color.white

func _on_Button_Shield_Aft_mouse_exited():
	texture_shields[1].modulate = COLOUR_DIM

func _on_Button_Shield_Port_mouse_entered():
	texture_shields[2].modulate = Color.white

func _on_Button_Shield_Port_mouse_exited():
	texture_shields[2].modulate = COLOUR_DIM

func _on_Button_Shield_Starboard_mouse_entered():
	texture_shields[3].modulate = Color.white

func _on_Button_Shield_Starboard_mouse_exited():
	texture_shields[3].modulate = COLOUR_DIM
