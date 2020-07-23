extends Node

# Singleton storing a few stats about how the game is going

enum GameOverReason {SHIP_DESTROYED, RESPONSE_TIMEOUT, TOO_MANY_WRONG_ANSWERS}

var game_start_time_msec : int
var missiles_fired : int
var asteroids_destroyed : int
var messages_sent : int

var game_end_time_msec : int
var game_over_reason : int

func get_time_survived_msec() -> int:
	return game_end_time_msec - game_start_time_msec

func new_game() -> void:
	game_start_time_msec = OS.get_ticks_msec()
	missiles_fired = 0
	asteroids_destroyed = 0
	messages_sent = 0

func game_over(reason : int) -> void:
	game_over_reason = reason
	game_end_time_msec = OS.get_ticks_msec()
