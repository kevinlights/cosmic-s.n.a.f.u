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
onready var label_no_power = $Label_NoPower

onready var audio_hover = $Audio_Hover
onready var audio_select = $Audio_Select

var game

func _draw() -> void:
	if not game.is_component_powered(2):
		for texture in texture_shields:
			texture.hide()
		label_no_power.show()
		return
	
	label_no_power.hide()
	for texture in texture_shields:
		texture.show()
	for i in range(0, SHIELD_STRINGS.size()):
		draw_string(ComputerFont, Vector2(-8, 72 + (i * 8)), SHIELD_STRINGS[i], COLOUR_DIM)
		if game.shield_state[i] != 2: # Not charing
			draw_string(ComputerFont, Vector2(32, 72 + (i * 8)), STATUS_STRINGS[game.shield_state[i]], Color.white)
		else:
			var recharge_status : String = str("%03d" % int(game.shield_recharge_rate[i] * 100)) + "%"
			draw_string(ComputerFont, Vector2(32, 72 + (i * 8)), recharge_status, Color.white)
	draw_string(ComputerFont, Vector2(-8, 112), "PWR DRAW", COLOUR_DIM)
	draw_string(ComputerFont, Vector2(-8, 120), str(game.get_shields_power_drain() * 100.0) + "KW", Color.white)

func update_shield_indicator(which : int, up : bool) -> void:
	texture_shields[which].visible = up

func _on_Button_Shield_Fore_pressed() -> void:
	if not game.is_component_powered(2): return
	emit_signal("shield_toggled", 0)
	audio_select.play()

func _on_Button_Shield_Aft_pressed() -> void:
	if not game.is_component_powered(2): return
	emit_signal("shield_toggled", 1)
	audio_select.play()

func _on_Button_Shield_Port_pressed() -> void:
	if not game.is_component_powered(2): return
	emit_signal("shield_toggled", 2)
	audio_select.play()

func _on_Button_Shield_Starboard_pressed() -> void:
	if not game.is_component_powered(2): return
	emit_signal("shield_toggled", 3)
	audio_select.play()

func _on_Button_Shield_Fore_mouse_entered():
	if not game.is_component_powered(2): return
	texture_shields[0].modulate = Color.white
	audio_hover.play()

func _on_Button_Shield_Fore_mouse_exited():
	texture_shields[0].modulate = COLOUR_DIM

func _on_Button_Shield_Aft_mouse_entered():
	if not game.is_component_powered(2): return
	texture_shields[1].modulate = Color.white
	audio_hover.play()

func _on_Button_Shield_Aft_mouse_exited():
	texture_shields[1].modulate = COLOUR_DIM

func _on_Button_Shield_Port_mouse_entered():
	if not game.is_component_powered(2): return
	texture_shields[2].modulate = Color.white
	audio_hover.play()

func _on_Button_Shield_Port_mouse_exited():
	texture_shields[2].modulate = COLOUR_DIM

func _on_Button_Shield_Starboard_mouse_entered():
	if not game.is_component_powered(2): return
	texture_shields[3].modulate = Color.white
	audio_hover.play()

func _on_Button_Shield_Starboard_mouse_exited():
	texture_shields[3].modulate = COLOUR_DIM
