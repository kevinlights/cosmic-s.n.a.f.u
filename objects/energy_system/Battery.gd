extends Control

const COLOUR_BRIGHT = Color.white
const COLOUR_DIM = Color("687f8a")

onready var button_select = $Button_Select
onready var button_refresh = $Button_Refresh
onready var texture_dead = $Texture_Dead
onready var label_recharging = $Label_Recharging
onready var indicator = $Button_Select/ChargeIndicator
onready var connector = $Connector
onready var audio_hover = $Audio_Hover
onready var audio_select = $Audio_Select

var which_battery : int
var selected : bool = false

signal battery_selected
signal battery_change_started

func refresh_indicator(state : int, charge : float, replacement_progress : float) -> void:
	match state:
		0: # on
			button_select.visible = true
			button_refresh.visible = true
			texture_dead.visible = false
			label_recharging.visible = false
			indicator.value = charge * 12
		1: # dead
			button_select.visible = false
			button_refresh.visible = true
			texture_dead.visible = true
			label_recharging.visible = false
		2: # changing
			button_select.visible = false
			button_refresh.visible = false
			texture_dead.visible = false
			label_recharging.visible = true
			label_recharging.text = str("%03d" % int(replacement_progress * 100)) + "%"

func _ready() -> void:
	indicator.modulate = COLOUR_DIM

func deselect() -> void:
	indicator.modulate = COLOUR_DIM
	selected = false

func _on_Button_Select_pressed():
	emit_signal("battery_selected", which_battery)
	selected = true
	audio_select.play()

func _on_Button_Refresh_pressed():
	emit_signal("battery_change_started", which_battery)
	audio_select.play()

# We need to fudge the button changing colour when hovered over, since the texture isn't part of the button itself
func _on_Button_Select_mouse_entered() -> void:
	indicator.modulate = COLOUR_BRIGHT
	audio_hover.play()

func _on_Button_Select_mouse_exited() -> void:
	if not selected:
		indicator.modulate = COLOUR_DIM

func _on_Button_Refresh_mouse_entered():
	audio_hover.play()
