extends Control

class Star:
	var position : Vector2
	var zoom : float

var stars : Array = []

func draw_stars() -> void:
	draw_set_transform(Vector2(160, 90), 0.0, Vector2.ONE)
	
