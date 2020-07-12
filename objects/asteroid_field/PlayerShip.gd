extends Area2D

class_name PlayerShip

const Missile = preload("res://objects/asteroid_field/PlayerMissile.tscn")

const TURNING_SPEED : float = 0.5
const TURN_RANDOMISE_AMOUNT : float = 0.5
const MISSILE_SPEED : float = 32.0

var speed : float = 8.0
var target_rotation : float = rotation

signal hit_by_asteroid

func hit_by_asteroid(asteroid : RigidBody2D) -> void:
	print("We've been hit!")
	asteroid.queue_free()
	emit_signal("hit_by_asteroid")

func _physics_process(delta : float) -> void:
	# Turn
	rotation = lerp_angle(rotation, target_rotation, delta * TURNING_SPEED)
	# Move
	var velocity = Vector2.RIGHT.rotated(rotation) * speed
	position += velocity * delta
	# Wrap
	if not AsteroidField.FIELD_BOUNDS.has_point(position):
		position = Vector2(
			wrapf(position.x, 0.0, AsteroidField.FIELD_BOUNDS.size.x),
			wrapf(position.y, 0.0, AsteroidField.FIELD_BOUNDS.size.y)
		)

func fire_missile() -> void:
	var missile = Missile.instance()
	missile.velocity = Vector2.RIGHT.rotated(rotation) * MISSILE_SPEED
	get_parent().add_child(missile)

# Our rudder's on the blink! We're drifting!
func _randomise_direction() -> void:
	target_rotation += (randf() - 0.5) * TURN_RANDOMISE_AMOUNT

func _on_PlayerShip_body_entered(body : PhysicsBody2D) -> void:
	if body.is_in_group("asteroid"):
		hit_by_asteroid(body)
