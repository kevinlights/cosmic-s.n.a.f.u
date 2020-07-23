extends Control

const COLOUR_HUD : Color = Color("687f8a")
const CLICK_BOUNDS : Rect2 = Rect2(0, 0, 88, 10)

var value : float = 0.0
var active : bool = false

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

func _process(delta : float) -> void:
	if not active:
		return
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		var mouse_pos : Vector2 = get_local_mouse_position()
		if CLICK_BOUNDS.has_point(mouse_pos):
			var new_value : float = mouse_pos.x / CLICK_BOUNDS.size.x
			value = new_value
			update()
			emit_signal("value_changed", value)
