extends Node2D

const Icons = preload("res://sprites/radar_objects.png")

const RADAR_RANGE : float = 96.0

var asteroid_field : Node2D
var player_ship : Area2D

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, deg2rad(-90.0), Vector2.ONE)
	# Draw player ship
	draw_texture_rect_region(Icons, Rect2(-8, -8, 16, 16), Rect2(0, 0, 8, 8))
	# Draw asteroids
	for asteroid in get_tree().get_nodes_in_group("asteroid"):
		var pos_relative_to_ship : Vector2 = asteroid.position - player_ship.position
		pos_relative_to_ship = Vector2(
			wrapf(pos_relative_to_ship.x, -256.0, 256.0),
			wrapf(pos_relative_to_ship.y, -256.0, 256.0)
		)
		# Is it out of range?
		if pos_relative_to_ship.length() > RADAR_RANGE:
			continue
		pos_relative_to_ship = pos_relative_to_ship.rotated(-player_ship.rotation)
		draw_texture_rect_region(Icons, Rect2(pos_relative_to_ship, Vector2(8, 8)), Rect2(8, 0, 8, 8))

func _physics_process(delta : float) -> void:
	update()
