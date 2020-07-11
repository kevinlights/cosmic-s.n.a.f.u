extends Node

onready var asteroid_field = $AsteroidField
onready var radar = $Radar
onready var energy_system = $EnergySystem

const ENERGY_SYSTEM_UPDATE_TIME : float = 0.25
const BATTERY_REPLACE_RATE : float = 0.25 # i.e. takes four seconds to replace

enum BatteryState {ON, DEAD, CHANGING}

var connections : Array = [0, 0, 1, 2, 1, -1, -1, 2]
var battery_charge_levels : Array = [0.2, 0.4, 0.9, 0.9, 0.8, 0.8, 0.7, 0.7]
var battery_state : Array = [BatteryState.ON, BatteryState.ON, BatteryState.ON, BatteryState.ON, BatteryState.ON, BatteryState.ON, BatteryState.ON, BatteryState.ON]
var battery_replacement_progress : Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var battery_drain_rates : Array = [0.02, 0.02, 0.03, 0.03, 0.04, 0.04, 0.05, 0.05]

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

func set_connection(battery : int, component : int) -> void:
	connections[battery] = component
	# Does this mean we need to override any existing connections?
	override_connections_if_needed(battery, component)

func start_changing_battery(battery : int) -> void:
	battery_state[battery] = BatteryState.CHANGING
	battery_replacement_progress[battery] = 0.0
	set_connection(battery, -1)
	energy_system.update_battery_indicators()

func is_battery_connected(battery : int) -> bool:
	return connections[battery] != -1

func is_battery_on(battery : int) -> bool:
	return battery_state[battery] == BatteryState.ON

func is_component_powered(component : int) -> bool:
	var power : int = 0
	for battery in range(0, connections.size()):
		var connection : int = connections[battery]
		if connection == component and is_battery_on(battery):
			power += 1
	return power >= 2

func _update_energy_system() -> void:
	# Drain the batteries
	for i in range(0, battery_charge_levels.size()):
		match battery_state[i]:
			BatteryState.ON:
				if is_battery_connected(i):
					battery_charge_levels[i] -= battery_drain_rates[i] * ENERGY_SYSTEM_UPDATE_TIME
					if battery_charge_levels[i] < 0.0:
						battery_state[i] = BatteryState.DEAD
						set_connection(i, -1)
			BatteryState.CHANGING:
				battery_replacement_progress[i] += BATTERY_REPLACE_RATE * ENERGY_SYSTEM_UPDATE_TIME
				if battery_replacement_progress[i] >= 1.0:
					battery_state[i] = BatteryState.ON
					battery_charge_levels[i] = 1.0
	energy_system.update_battery_indicators()
	energy_system.refresh_component_alerts()
	energy_system.update()

func start_game() -> void:
	battery_charge_levels.shuffle()
	battery_drain_rates.shuffle()

func _ready() -> void:
	radar.asteroid_field = asteroid_field
	radar.player_ship = asteroid_field.player_ship
	energy_system.game = self
	start_game()
