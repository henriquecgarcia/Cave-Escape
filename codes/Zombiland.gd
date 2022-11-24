extends Node2D

onready var Zombies = $Zombies
onready var timer = $Zombie_Spawn_Timer
onready var rng = RandomNumberGenerator.new()
onready var spawn = $Spawns
onready var Player = $Player
onready var textDisplay = $UI/CenterText

var spawnedZombies = 0
var spawned = []
var zCode = preload("res://scenes/Zombie.tscn")

func randomPos( mult = 1 ):
	var cc = spawn.get_child_count()
	var r = (rng.randi_range(0, cc * mult) + mult + cc )% cc
	if not spawned[r]:
		return r
	var z = spawned[r]
	var pPos = spawn.get_child(r).position
	if is_instance_valid(z) and z.position == pPos:
		return randomPos( mult+1 )
	spawned[r] = null
	return r

func createZombies(amount = 1):
	for i in amount:
		var r = randomPos()
		var pPos = spawn.get_child(r).position
		var b = zCode.instance()
		b.position = pPos
		Zombies.add_child(b)
		spawnedZombies += 1
		spawned[r] = b

func _ready():
	randomize()
	timer.start(3)
	for i in range(spawn.get_child_count()):
		spawned.append(null)
	textDisplay = ""

func GetAliveZombies():
	return Zombies.get_child_count()

func _on_Zombie_Spawn_Timer_timeout():
	if not Player.IsAlive():
		return
	createZombies(1)
	timer.start(2)
