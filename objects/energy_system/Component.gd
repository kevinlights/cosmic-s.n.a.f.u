extends Control

export(int, "Engines", "Radio", "Shields") var which_component

onready var button = $Button
onready var alert_l = $AlertL
onready var alert_r = $AlertR
onready var connector_l = $ConnectorL
onready var connector_r = $ConnectorR

signal component_selected

func update_icon() -> void:
	button.texture_normal = button.texture_normal.duplicate()
	button.texture_hover = button.texture_hover.duplicate()
	button.texture_pressed = button.texture_pressed.duplicate()
	button.texture_normal.region.position.x = (1 + which_component) * 16
	button.texture_hover.region.position.x = (1 + which_component) * 16
	button.texture_pressed.region.position.x = (1 + which_component) * 16

func _ready() -> void:
	update_icon()

func _on_Button_pressed():
	emit_signal("component_selected", which_component)
