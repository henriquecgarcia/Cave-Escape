extends Node

export var max_health = 1 setget set_max_health
export var max_ammo = 1 setget set_max_ammo
var health = max_health setget set_health
var ammo = max_ammo setget set_ammo
var kills = 0 setget set_kills

var weapons = []

signal max_health_changed(value)
signal health_changed(value)
signal no_health
signal max_ammo_changed(value)
signal ammo_changed(value)
signal no_ammo
signal kills_changed(value)

func set_health(value):
	health = clamp(value, 0, max_health)
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func set_max_health(value):
	max_health = max(1, value)
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_ammo(value):
	ammo = clamp(value, 0, max_ammo)
	emit_signal("ammo_changed", ammo)
	if ammo <= 0:
		emit_signal("no_ammo")

func set_max_ammo(value):
	max_ammo = max(value, 1)
	self.ammo = min(ammo, max_ammo)
	emit_signal("max_ammo_changed", max_ammo)

func set_kills(value):
	kills = max(0, value)
	emit_signal("kills_changed", kills)

func add_weapon(weapon : String = "handgun", wammo : int = 10, mags : int = 0, damage : int = 20):
	var dat = {
		"name": weapon,
		"ammo": wammo,
		"mags": mags,
		"dmg": damage,
	}
	weapons.append(dat)

func get_weapon_index(weapon := "handgun"):
	for i in range(len(weapons)):
		if weapons[i].name == weapon:
			return i
	return -1

func add_magazine( weapon :String="handgun", value : int = 1 ):
	var index = get_weapon_index(weapon)
	if index < 0:
		return
	value = int( max(value, 0) )
	weapons[index].mags += value

func _ready():
	self.health = max_health
	self.ammo = max_ammo
