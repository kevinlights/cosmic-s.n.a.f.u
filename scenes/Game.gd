extends Node

onready var asteroid_field = $AsteroidField
onready var radar = $Radar

func _ready():
	radar.asteroid_field = asteroid_field
	radar.player_ship = asteroid_field.player_ship
