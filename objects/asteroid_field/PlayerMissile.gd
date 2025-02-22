extends Area2D

var velocity : Vector2

var game

func _physics_process(delta : float) -> void:
	position += velocity * delta
	position = Vector2(
		wrapf(position.x, 0.0, 512.0), # Probably shouldn't hard-code this, but I don't see it changing in the next nine hours.
		wrapf(position.y, 0.0, 512.0)
	)

func _on_PlayerMissile_body_entered(body):
	if body.is_in_group("asteroid"):
		get_tree().call_group("game", "missile_destroyed_asteroid") # janky hack
		body.queue_free()
		self.queue_free()

func _on_Timer_Despawn_timeout():
	queue_free()
