extends Node2D

onready var Zombies = $Zombies
onready var timer = $Zombie_Spawn_Timer

var spawnedZombies = 0
var zCode = preload("res://codes/Zombie.tscn")

func createZombies(amount = 1):
	for i in amount:
		#var pPos = Vector2(randf(), randf())
		var pPos = Vector2(20, 20)
		var b = zCode.instance()
		b.position = pPos
		Zombies.add_child(b)
		spawnedZombies += 1

func _ready():
	randomize()
	timer.start(3)

func GetAliveZombies():
	return Zombies.get_child_count()

func _on_Zombie_Spawn_Timer_timeout():
	createZombies(1)
	timer.start(2)
