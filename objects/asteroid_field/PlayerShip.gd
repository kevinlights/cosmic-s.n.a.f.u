extends Area2D

class_name PlayerShip

const Missile = preload("res://objects/asteroid_field/PlayerMissile.tscn")

const TURNING_SPEED : float = 0.5
const TURN_RANDOMISE_AMOUNT : float = 0.5
const MISSILE_SPEED : float = 32.0

#onready var collision_shape_fore = $Area2D_Shield_Fore/CollisionShape2D_Fore
#onready var collision_shape_aft = $Area2D_Shield_Aft/CollisionShape2D_Aft
#onready var collision_shape_port = $Area2D_Shield_Port/CollisionShape2D_Port
#onready var collision_shape_starboard = $Area2D_Shield_Starboard/CollisionShape2D_Starboard

onready var collision_shape_shields : Array = [
	$Area2D_Shield_Fore/CollisionShape2D_Fore,
	$Area2D_Shield_Aft/CollisionShape2D_Aft,
	$Area2D_Shield_Port/CollisionShape2D_Port,
	$Area2D_Shield_Starboard/CollisionShape2D_Starboard
]

var speed : float = 8.0
var target_rotation : float = rotation

signal hit_by_asteroid
signal asteroid_hit_shield

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
	missile.global_position = global_position
	missile.velocity = Vector2.RIGHT.rotated(rotation) * MISSILE_SPEED
	get_parent().add_child(missile)

func set_shield_up(which_shield : int, up : bool) -> void:
	collision_shape_shields[which_shield].disabled = !up

# Our rudder's on the blink! We're drifting!
func _randomise_direction() -> void:
	target_rotation += (randf() - 0.5) * TURN_RANDOMISE_AMOUNT

func shields_hit(body : PhysicsBody2D, which_shield : int) -> void:
	if body.is_in_group("asteroid"):
		body.queue_free()
		emit_signal("asteroid_hit_shield", which_shield)

func _on_Area2D_Shield_Fore_body_entered(body : PhysicsBody2D) -> void:
	shields_hit(body, 0)

func _on_Area2D_Shield_Aft_body_entered(body : PhysicsBody2D) -> void:
	shields_hit(body, 1)

func _on_Area2D_Shield_Port_body_entered(body : PhysicsBody2D) -> void:
	shields_hit(body, 2)

func _on_Area2D_Shield_Starboard_body_entered(body : PhysicsBody2D) -> void:
	shields_hit(body, 3)

func _on_PlayerShip_body_entered(body : PhysicsBody2D) -> void:
	if body.is_in_group("asteroid"):
		hit_by_asteroid(body)
