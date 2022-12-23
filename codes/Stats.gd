extends Node

export var max_health = 1 setget set_max_health
export var max_ammo = 1 setget set_max_ammo
var health = max_health setget set_health
var ammo = max_ammo setget set_ammo

signal max_health_changed(value)
signal health_changed(value)
signal no_health
signal max_ammo_changed(value)
signal ammo_changed(value)
signal no_ammo

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

func _ready():
	self.health = max_health
	self.ammo = max_ammo
