extends Control

const COLOUR_BRIGHT = Color("eca400")
const COLOUR_DIM = Color("bd8400")

onready var button_refresh = $Button_Refresh
onready var label_recharging = $Label_Recharging
onready var indicator = $Button_Select/ChargeIndicator
onready var connector = $Connector

onready var charge : float = randf()
var which_battery : int
var selected : bool = false

signal battery_selected

func refresh_charge_indicator() -> void:
	indicator.value = charge * 12
	label_recharging.text = str("%03d" % int(charge * 100)) + "%"

func _ready() -> void:
	refresh_charge_indicator()
	indicator.modulate = COLOUR_DIM

func deselect() -> void:
	indicator.modulate = COLOUR_DIM
	selected = false

func _on_Button_Select_pressed():
	emit_signal("battery_selected", which_battery)
	selected = true

func _on_Button_Refresh_pressed():
	pass # Replace with function body.

# We need to fudge the button changing colour when hovered over, since the texture isn't part of the button itself
func _on_Button_Select_mouse_entered() -> void:
	indicator.modulate = COLOUR_BRIGHT

func _on_Button_Select_mouse_exited() -> void:
	if not selected:
		indicator.modulate = COLOUR_DIM
