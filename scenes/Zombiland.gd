extends Node2D

onready var Zombies = $Zombies
onready var timer = $Zombie_Spawn_Timer
onready var rng = RandomNumberGenerator.new()
onready var Player = $Player

var spawnedZombies = 0
var zCode = preload("res://codes/Zombie.tscn")

func createZombies(amount = 1):
	for i in amount:
		var r = rng.randi_range(0, $Spawns.get_child_count())
		var pPos = $Spawns.get_child(r).position
		#print(r, pPos)
		#var pPos = Vector2(20, 20)
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
	if not Player.IsAlive():
		return
	createZombies(1)
	timer.start(2)
