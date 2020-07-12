extends Node

# This singleton is just to let the game over screen know why the game ended.

enum GameOverReason {SHIP_DESTROYED, RESPONSE_TIMEOUT, TOO_MANY_WRONG_ANSWERS}

var game_over_reason : int

var asteroids_destroyed : int

func new_game() -> void:
	asteroids_destroyed = 0
