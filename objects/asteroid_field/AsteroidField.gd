extends Node2D

class_name AsteroidField

const Asteroid = preload("res://objects/asteroid_field/Asteroid.tscn")

const ASTEROID_COUNT : int = 128
const ASTEROID_VELOCITY : float = 4.0
const FIELD_BOUNDS : Rect2 = Rect2(0, 0, 512, 512)

onready var player_ship = $PlayerShip

func spawn_asteroids() -> void:
	for i in range(0, ASTEROID_COUNT):
		var asteroid = Asteroid.instance()
		asteroid.position = Vector2(randf(), randf()) * FIELD_BOUNDS.size
		asteroid.linear_velocity = Vector2(randf(), randf()) * ASTEROID_VELOCITY
		add_child(asteroid)

# Turns out you can't use wrapf() to keep asteroids inside the play area.
# Instead, if an asteroid moves outside that bounds, we despawn it, and spawn
# another one where it should be.
func wrap_asteroids() -> void:
	for asteroid in get_tree().get_nodes_in_group("asteroid"):
		if not FIELD_BOUNDS.has_point(asteroid.position):
			var new_pos : Vector2 = Vector2(
				wrapf(asteroid.position.x, 0.0, FIELD_BOUNDS.size.x),
				wrapf(asteroid.position.y, 0.0, FIELD_BOUNDS.size.y)
			)
			var replacement = Asteroid.instance()
			replacement.position = new_pos
			replacement.linear_velocity = asteroid.linear_velocity
			add_child(replacement)
			asteroid.queue_free()

func _update_asteroids():
	wrap_asteroids()

func _ready() -> void:
	spawn_asteroids()


