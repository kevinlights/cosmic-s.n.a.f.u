extends Control

const Signal : AudioStreamOGGVorbis = preload("res://data/signal.ogg")

const COLOUR_HUD = Color("687f8a")

const WAVEFORM_INCR : int = 24
const WAVEFORM_CHUNK : int = 64

var signal_strength : float = 0.5
var waveform_position : int = 0

func _draw() -> void:
	draw_line(Vector2(0, 32), Vector2(128, 32), COLOUR_HUD)
	draw_line(Vector2(0, 0), Vector2(0, 64), COLOUR_HUD)
	draw_line(Vector2(128, 0), Vector2(128, 64), COLOUR_HUD)
	var points : Array = []
	for i in range(0, WAVEFORM_CHUNK):
		# I'm not proud of this line.
		var amplitude : float = (float(wrapi(Signal.data[waveform_position + i] + 128, 0, 256)) / 256.0) - 0.5
		points.append(Vector2(i * 2.0, amplitude * signal_strength * 64.0) + Vector2(0, 32))
	draw_polyline(points, COLOUR_HUD)

func update_waveform() -> void:
	update()
	waveform_position += WAVEFORM_INCR
	if waveform_position >= Signal.data.size() - WAVEFORM_CHUNK:
		waveform_position = 0
