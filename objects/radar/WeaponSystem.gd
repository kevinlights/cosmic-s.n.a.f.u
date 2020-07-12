extends Control

onready var weapon_box = $Weapons
onready var label_no_power = $Label_NoPower

onready var weapons : Array = [
	$Weapons/WeaponIndicator1,
	$Weapons/WeaponIndicator2
]

var game

signal fire_weapon

func update_indicators() -> void:
	if game.is_component_powered(0):
		label_no_power.hide()
		weapon_box.show()
		for i in range(0, weapons.size()):
			var weapon = weapons[i]
			weapon.update_indicator(game.weapon_ready[i], game.weapon_recharge_progress[i])
	else:
		label_no_power.show()
		weapon_box.hide()

func fire_weapon(which_weapon : int) -> void:
	emit_signal("fire_weapon", which_weapon)

func _ready() -> void:
	for i in range(0, weapons.size()):
		weapons[i].set_label_text("WPN" + str(i + 1))
		weapons[i].which_weapon = i
		weapons[i].connect("fire_weapon", self, "fire_weapon")
