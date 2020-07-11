extends Control

const CONNECTOR_COLOUR : Color = Color("eca400")

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

var connections : Array = [0, 0, 1, 2, 1, -1, -1, 2]

var selected_battery : int = -1
var selected_component : int = -1

func battery_selected(which : int) -> void:
	# Deselect the old battery
	if selected_battery != -1:
		batteries[selected_battery].deselect()
	selected_battery = which

func do_connections_overlap(battery_a : int, component_a : int, battery_b : int, component_b : int) -> bool:
	# If the two batteries or the two components are the same, the connections cannot overlap
	if battery_a == battery_b or component_a == component_b:
		return false
	var battery_a_float : float = float(battery_a) if battery_a < 4 else float(battery_a - 4)
	var component_a_float : float = float(component_a) + 0.5
	var battery_b_float : float = float(battery_b) if battery_b < 4 else float(battery_b - 4)
	var component_b_float : float = float(component_b) + 0.5
	if battery_a_float > battery_b_float:
		return component_a_float < component_b_float
	else:
		return component_a_float > component_b_float

func override_connections_if_needed(battery : int, component : int) -> void:
	var range_start : int = 0 if battery < 4 else 4
	var range_end : int = 4 if battery < 4 else 8
	for comparing_battery in range(range_start, range_end):
		# Don't compare this connection to itself!
		if comparing_battery == battery:
			continue
		var comparing_component : int = connections[comparing_battery]
		# Make this this connection actually exists
		if comparing_component == -1:
			continue
		# Okay, this connection might need to go
		if do_connections_overlap(battery, component, comparing_battery, comparing_component):
			connections[comparing_battery] = -1

func component_selected(which_component : int) -> void:
	if selected_battery != -1:
		# Connect the battery to the component
		connections[selected_battery] = which_component
		# Does this mean we need to override any existing connections?
		override_connections_if_needed(selected_battery, which_component)
		# Deselect the battery, and redraw the connections
		batteries[selected_battery].deselect()
		selected_battery = -1
		update()

func setup_connections() -> void:
	for i in range(0, batteries.size()):
		var battery = batteries[i]
		battery.which_battery = i
		battery.connect("battery_selected", self, "battery_selected")
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
	for i in range(0, connections.size()):
		var connection : int = connections[i]
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
