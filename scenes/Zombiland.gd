extends Node2D

onready var Zombies = $Zombies
onready var timer = $Zombie_Spawn_Timer

var curZombies = 0
var spawnedZombies = 0
var zCode = preload("res://codes/Zombie.tscn")

func createZombies(amount = 1):
	for i in amount:
		var b = zCode.instance()
		b.position = Vector2(10, 10)
		Zombies.add_child(b)
		curZombies += 1

func _ready():
	randomize()
	timer.start(3)

func _on_Zombie_Spawn_Timer_timeout():
	createZombies(1)
	timer.start(2)
