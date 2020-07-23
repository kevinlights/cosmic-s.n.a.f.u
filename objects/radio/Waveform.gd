extends Control

const Signal : AudioStreamOGGVorbis = preload("res://data/signal.ogg")

const COLOUR_HUD = Color("687f8a")
const WAVEFORM_WIDTH : int = 240
const WAVEFORM_INCR : int = 24
const WAVEFORM_CHUNK : int = 80

var signal_strength : float = 0.5
var waveform_position : int = 0

func _draw() -> void:
	draw_line(Vector2(0, 32), Vector2(WAVEFORM_WIDTH, 32), COLOUR_HUD)
	draw_line(Vector2(0, 0), Vector2(0, 64), COLOUR_HUD)
	draw_line(Vector2(WAVEFORM_WIDTH, 0), Vector2(WAVEFORM_WIDTH, 64), COLOUR_HUD)
	var points : Array = []
	for i in range(0, WAVEFORM_CHUNK):
		# I'm not proud of these lines.
		var x : float = (float(i) / float(WAVEFORM_CHUNK-1)) * float(WAVEFORM_WIDTH)
		var amplitude : float = (float(wrapi(Signal.data[waveform_position + i] + 128, 0, 256)) / 256.0) - 0.5
		points.append(Vector2(x, amplitude * signal_strength * 64.0) + Vector2(0, 32))
	draw_polyline(points, COLOUR_HUD)

func update_waveform() -> void:
	update()
	waveform_position += WAVEFORM_INCR
	if waveform_position >= Signal.data.size() - WAVEFORM_CHUNK:
		waveform_position = 0
