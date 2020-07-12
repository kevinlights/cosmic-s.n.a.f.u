extends Control

const Icons = preload("res://sprites/radar_objects.png")

onready var timer_update = $Timer_Update
onready var label_no_signal = $Label_NoSignal
onready var button_zoom_out = $Button_ZoomOut
onready var button_zoom_in = $Button_ZoomIn
onready var shield_indicator = $ShieldIndicator

const COLOUR_HUD = Color("687f8a")

const RADAR_RANGE : Array = [64.0, 128.0, 256.0]
const RING_INTERVAL : Array = [32.0, 16.0, 8.0] 
const SCALING : Array = [1.0, 0.5, 0.25]
const REFRESH_RATE : Array = [0.25, 0.5, 1.0]

var asteroid_field : Node2D
var player_ship : Area2D
var game

var zoom_level : int = 1

signal back_from_radar
signal fire_missile
signal shield_toggled

# Why doesn't Godot have this built in!?
func draw_circle_outline(pos : Vector2, size : float, colour : Color) -> void:
	var points : Array = []
	for i in range(0, 19):
		points.append(pos + (Vector2.RIGHT.rotated(deg2rad(i * 20.0)) * size))
	draw_polyline(points, colour)

func _draw() -> void:
	if not game.signal_is_good():
		return
	draw_set_transform(Vector2(160, 84), deg2rad(-90.0), Vector2(1.0, 1.0))
	# Draw rings
	for i in range(0.0, 65.0, RING_INTERVAL[zoom_level]):
		draw_circle_outline(Vector2(0, 0), i, COLOUR_HUD)
	# Draw player ship
	draw_texture_rect_region(Icons, Rect2(-8, -8, 16, 16), Rect2(0, 16*zoom_level, 16, 16))
	# Draw asteroids
	for asteroid in get_tree().get_nodes_in_group("asteroid"):
		var pos_relative_to_ship : Vector2 = asteroid.position - player_ship.position
		pos_relative_to_ship = Vector2(
			wrapf(pos_relative_to_ship.x, -256.0, 256.0),
			wrapf(pos_relative_to_ship.y, -256.0, 256.0)
		)
		# Is it out of range?
		if pos_relative_to_ship.length() > RADAR_RANGE[zoom_level]:
			continue
		pos_relative_to_ship = pos_relative_to_ship.rotated(-player_ship.rotation)
		pos_relative_to_ship *= SCALING[zoom_level]
		draw_texture_rect_region(Icons, Rect2(pos_relative_to_ship - Vector2(8, 8), Vector2(16, 16)), Rect2(16, 16*zoom_level, 16, 16))

func update_radar():
	update()
	label_no_signal.visible = !game.signal_is_good()
	button_zoom_in.visible = game.signal_is_good()
	button_zoom_out.visible = game.signal_is_good()

func _fire_missile() -> void:
	emit_signal("fire_missile")

func _shield_toggled(which : int) -> void:
	emit_signal("shield_toggled", which)

func _zoom_out():
	zoom_level = clamp(zoom_level + 1, 0, 2)
	update()
	timer_update.start(REFRESH_RATE[zoom_level])

func _zoom_in():
	zoom_level = clamp(zoom_level - 1, 0, 2)
	update()
	timer_update.start(REFRESH_RATE[zoom_level])

func _on_Button_Back_pressed():
	emit_signal("back_from_radar")
