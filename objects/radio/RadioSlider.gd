extends Control

const COLOUR_HUD = Color("687f8a")

var value : float = 0.0

signal value_changed

func _draw() -> void:
	draw_line(Vector2(0, 0), Vector2(0, 16), COLOUR_HUD)
	draw_line(Vector2(88, 0), Vector2(88, 16), COLOUR_HUD)
	draw_line(Vector2(0, 8), Vector2(88, 8), COLOUR_HUD)
	for i in range(8, 88, 8):
		draw_line(Vector2(i, 4), Vector2(i, 12), COLOUR_HUD)
	# Draw the moving bit
	var slider_position : int = stepify(wrapf(value, 0.0, 1.0), 0.1) * 80
	draw_rect(Rect2(1 + slider_position, 2, 5, 12), Color.white)

func _input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		var cursor : Vector2 = event.position
		if Rect2(rect_global_position, Vector2(88, 16)).has_point(cursor):
			var new_value : float = float(cursor.x - rect_global_position.x) / 88.0
			value = new_value
			update()
			emit_signal("value_changed", value)
