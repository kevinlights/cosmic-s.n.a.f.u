extends Node

onready var asteroid_field = $AsteroidField
onready var phone_system = $PhoneSystem
onready var shaker = $Shaker
onready var cockpit = $Shaker/Cockpit
onready var radar = $Shaker/Radar
onready var energy_system = $Shaker/EnergySystem
onready var radio = $Shaker/Radio
onready var phone = $Shaker/Phone
onready var starfield = $Starfield

const ENERGY_SYSTEM_UPDATE_TIME : float = 0.25
const BATTERY_REPLACE_RATE : float = 0.1
const SIGNAL_THRESHOLD : float = 0.3
const SHIELD_CHARGE_RATE : float = 0.25
const SHIELDS_DELTA : float = 0.25

enum BatteryState {ON, DEAD, CHANGING}
enum ShieldState {ON, OFF, CHARGING}

var connections : Array = [0, 0, 1, 2, 1, -1, -1, 2]
var battery_charge_levels : Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var battery_state : Array = [BatteryState.ON, BatteryState.ON, BatteryState.ON, BatteryState.ON, BatteryState.ON, BatteryState.ON, BatteryState.ON, BatteryState.ON]
var battery_replacement_progress : Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
var battery_drain_rates : Array = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

var radio_angle : float = 0.5
var radio_frequency : float = 0.5

var signal_strength : float = 0.5

var shield_state : Array = [ShieldState.ON, ShieldState.ON, ShieldState.ON, ShieldState.ON]
var shield_recharge_rate : Array = [0.0, 0.0, 0.0, 0.0]
var health : int = 3

var shake_amount : float = 0.0

func go_to_radar() -> void:
	cockpit.hide()
	radar.show()
	MusicManager.switch_to_track("steering")

func go_to_energy_system() -> void:
	cockpit.hide()
	energy_system.show()
	MusicManager.switch_to_track("power")

func go_to_radio() -> void:
	cockpit.hide()
	radio.show()
	MusicManager.switch_to_track("radar")

func go_to_phone() -> void:
	cockpit.hide()
	phone.show()
	phone.appear()
	MusicManager.switch_to_track("phone")

func back_from_radar() -> void:
	radar.hide()
	cockpit.show()
	MusicManager.switch_to_track("main")

func back_from_energy_system() -> void:
	energy_system.hide()
	cockpit.show()
	MusicManager.switch_to_track("main")

func back_from_radio() -> void:
	radio.hide()
	cockpit.show()
	MusicManager.switch_to_track("main")

func back_from_phone() -> void:
	phone.hide()
	cockpit.show()
	MusicManager.switch_to_track("main")

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

func signal_is_good() -> bool:
	return signal_strength > SIGNAL_THRESHOLD

func evaluate_signal_source(signal_source) -> float:
	var relative_position : Vector2 = signal_source.global_position - asteroid_field.player_ship.global_position
	# Get ready for some high-quality jank!
	var radar_direction : Vector2 = Vector2.RIGHT.rotated(radio_angle * PI * 2.0)
	var direction_match : float = (relative_position.normalized() - radar_direction).length() / 2.0
	var frequency_match : float = abs(sin(signal_source.frequency) * cos(radio_frequency * PI * 2.0))
	var signal_strength : float = 1.0 - clamp(relative_position.length() / 320.0, 0.0, 1.0)
	return direction_match * frequency_match * signal_strength

func _update_radio() -> void:
	var best_signal : float = 0.0
	for signal_source in get_tree().get_nodes_in_group("signal_source"):
		best_signal = max(best_signal, evaluate_signal_source(signal_source))
	signal_strength = best_signal
	radio.set_signal_strength(best_signal)

func _update_shields() -> void:
	for i in range(0, shield_state.size()):
		match shield_state[i]:
			ShieldState.CHARGING:
				shield_recharge_rate[i] += SHIELD_CHARGE_RATE * SHIELDS_DELTA
				if shield_recharge_rate[i] >= 1.0:
					shield_state[i] = ShieldState.ON
					shield_recharge_rate[i] = 0
	set_shields_up()
	radar.shield_indicator.update()

func get_shields_power_drain() -> float:
	var result : float = 0.0
	for i in range(0, shield_state.size()):
		match shield_state[i]:
			ShieldState.OFF:
				result += 0.025
			ShieldState.ON:
				result += 0.1
			ShieldState.CHARGING:
				result += 0.5
	return result

func set_shields_up() -> void:
	for i in range(0, shield_state.size()):
		asteroid_field.player_ship.set_shield_up(i, shield_state[i] == ShieldState.ON)
		#radar.shield_indicator.update_shield_indicator(i, shield_state[i] == ShieldState.ON)

func asteroid_hit_shield(which_shield : int) -> void:
	shield_state[which_shield] = ShieldState.CHARGING
	shield_recharge_rate[which_shield] = 0.0

func shield_toggled(which_shield : int) -> void:
	if shield_state[which_shield] == ShieldState.ON:
		shield_state[which_shield] = ShieldState.OFF
	else:
		shield_state[which_shield] = ShieldState.CHARGING
		shield_recharge_rate[which_shield] = 0.0
	radar.shield_indicator.update()

func ship_hit_by_asteroid() -> void:
	shake_amount = 1.0
	health -= 1
	MusicManager.increase_pitch()
	MusicManager.set_drums(true)
	if health <= 0:
		GameState.game_over_reason = GameState.GameOverReason.SHIP_DESTROYED
		MusicManager.stop_music_suddenly()
		get_tree().change_scene("res://scenes/GameOver.tscn")

func fire_missile() -> void:
	asteroid_field.player_ship.fire_missile()

func _new_message_received(index : int) -> void:
	var body : String = phone_system.get_message_body(index)
	var responses : Array = phone_system.get_message_responses(index)
	phone.set_message_body(body)
	phone.set_responses(responses)
	cockpit.set_phone_active(true)
	print("VRRR!") # TODO: actual sound effect

func response_sent(which_response : int) -> void:
	cockpit.set_phone_active(false)
	phone_system.evaluate_response(which_response)

func _too_many_wrong_answers():
	GameState.game_over_reason = GameState.GameOverReason.TOO_MANY_WRONG_ANSWERS
	MusicManager.stop_music_suddenly()
	get_tree().change_scene("res://scenes/GameOver.tscn")

func _message_response_timeout():
	GameState.game_over_reason = GameState.GameOverReason.RESPONSE_TIMEOUT
	MusicManager.stop_music_suddenly()
	get_tree().change_scene("res://scenes/GameOver.tscn")

func _process(delta : float) -> void:
	# Shake it, baby
	if shake_amount > 0.0:
		shaker.rect_position = Vector2(0.0, randf() * -16.0 * pow(shake_amount, 2.0))
		shake_amount -= delta
	else:
		shaker.rect_position = Vector2.ZERO
	# Move starfield
	starfield.rect_position.x = (wrapf(-asteroid_field.player_ship.rotation / PI, 0.0, 1.0) * 640.0) - 640.0

func start_game() -> void:
	randomize()
	cockpit.set_phone_active(false)
	phone_system.start_system()
	health = 3
	for i in range(0, connections.size()):
		battery_charge_levels[i] = (randf() + 1.0) / 2.0
		battery_drain_rates[i] = (randf() + 1.0) / 100.0

func _ready() -> void:
	# Set up the various nodes! Yes, this is a complete hodge-podge.
	cockpit.connect("go_to_radar", self, "go_to_radar")
	cockpit.connect("go_to_energy_system", self, "go_to_energy_system")
	cockpit.connect("go_to_radio", self, "go_to_radio")
	cockpit.connect("go_to_phone", self, "go_to_phone")
	radar.connect("back_from_radar", self, "back_from_radar")
	radar.connect("fire_missile", self, "fire_missile")
	radar.connect("shield_toggled", self, "shield_toggled")
	energy_system.connect("back_from_energy_system", self, "back_from_energy_system")
	radio.connect("back_from_radio", self, "back_from_radio")
	phone.connect("response_sent", self, "response_sent")
	phone.connect("back_from_phone", self, "back_from_phone")
	asteroid_field.player_ship.connect("hit_by_asteroid", self, "ship_hit_by_asteroid")
	asteroid_field.player_ship.connect("asteroid_hit_shield", self, "asteroid_hit_shield")
	radar.asteroid_field = asteroid_field
	radar.player_ship = asteroid_field.player_ship
	energy_system.game = self
	radar.game = self
	radar.shield_indicator.game = self
	radio.game = self
	# Game on!
	start_game()
	MusicManager.start_music()
