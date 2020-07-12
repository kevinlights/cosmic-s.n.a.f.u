extends Control

const CONNECTOR_COLOUR : Color = Color("687f8a")

onready var batteries : Array = [
	$BatteriesL/BatteryL1,
	$BatteriesL/BatteryL2,
	$BatteriesL/BatteryL3,
	$BatteriesL/BatteryL4,
	$BatteriesR/BatteryR1,
	$BatteriesR/BatteryR2,
	$BatteriesR/BatteryR3,
	$BatteriesR/BatteryR4
]

onready var components : Array = [
	$Components/Component1,
	$Components/Component2,
	$Components/Component3
]

onready var audio_connected = $Audio_Connected

var selected_battery : int = -1
var selected_component : int = -1

var game

signal back_from_energy_system

func battery_selected(which_battery : int) -> void:
	# Deselect the old battery
	if selected_battery != -1:
		batteries[selected_battery].deselect()
	selected_battery = which_battery

func component_selected(which_component : int) -> void:
	if selected_battery != -1:
		# Connect the battery to the component
		game.set_connection(selected_battery, which_component)
		# Deselect the battery, and redraw the connections
		batteries[selected_battery].deselect()
		selected_battery = -1
		update()
		audio_connected.play()

func battery_change_started(which_battery : int) -> void:
	game.start_changing_battery(which_battery)

func refresh_component_alerts() -> void:
	for i in range(0, components.size()):
		if game.is_component_powered(i):
			components[i].set_alerts_visible(false, false)
		else:
			components[i].set_alerts_visible(true, true)

func update_battery_indicators() -> void:
	for i in range(0, batteries.size()):
		batteries[i].refresh_indicator(
			game.battery_state[i],
			game.battery_charge_levels[i],
			game.battery_replacement_progress[i]
		)

func setup_connections() -> void:
	for i in range(0, batteries.size()):
		var battery = batteries[i]
		battery.which_battery = i
		battery.connect("battery_selected", self, "battery_selected")
		battery.connect("battery_change_started", self, "battery_change_started")
	for component in components:
		component.connect("component_selected", self, "component_selected")

func draw_neat_line(from : Vector2, to : Vector2) -> void:
	var point_a : Vector2
	var point_b : Vector2
	var distance_x : float = abs(to.x - from.x)
	var distance_y : float = abs(to.y - from.y)
	if distance_x > distance_y:
		var avg_y : float = (from.y + to.y) / 2.0
		point_a = Vector2(from.x, avg_y)
		point_b = Vector2(to.x, avg_y)
		var diagonal_length : float = distance_y / 2.0
		if to.x > from.x:
			point_a.x += diagonal_length
			point_b.x -= diagonal_length
		else:
			point_a.x -= diagonal_length
			point_b.x += diagonal_length
	else:
		var avg_x : float = (from.x + to.x) / 2.0
		point_a = Vector2(avg_x, from.y)
		point_b = Vector2(avg_x, to.y)
		var diagonal_length : float = distance_x / 2.0
		if to.y > from.y:
			point_a.y += diagonal_length
			point_b.y -= diagonal_length
		else:
			point_a.y -= diagonal_length
			point_b.y += diagonal_length
	draw_line(from, point_a, CONNECTOR_COLOUR)
	draw_line(point_a, point_b, CONNECTOR_COLOUR)
	draw_line(point_b, to, CONNECTOR_COLOUR)

func _draw() -> void:
	for i in range(0, game.connections.size()):
		var connection : int = game.connections[i]
		if connection == -1:
			continue
		var battery = batteries[i]
		var component = components[connection]
		var end_point : Vector2
		if i < 4:
			end_point = component.connector_l.rect_global_position
		else:
			end_point = component.connector_r.rect_global_position
		draw_neat_line(battery.connector.rect_global_position, end_point)

func _ready() -> void:
	setup_connections()

func _on_Button_Back_pressed():
	emit_signal("back_from_energy_system")
