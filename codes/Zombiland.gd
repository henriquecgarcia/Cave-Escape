extends Node2D

onready var Zombies = $Zombies
onready var timer = $Zombie_Spawn_Timer
onready var rng = RandomNumberGenerator.new()
onready var spawn = $Spawns
onready var Player = $Player
onready var textDisplay = $UI/CenterText
onready var nav = $nav

var spawnedZombies = 0
var spawned = []
var paused = false
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
	if paused:
		return
	for i in amount:
		var r = randomPos()
		var pPos = spawn.get_child(r).position
		var b = zCode.instance()
		b.position = pPos
		Zombies.add_child(b)
		b.nav = nav
		spawnedZombies += 1
		spawned[r] = b

func _ready():
	randomize()
	timer.start(3)
# warning-ignore:unused_variable
	for i in range(spawn.get_child_count()):
		spawned.append(null)
	textDisplay.text = ""
	Player.connect("PlayerDie", self, "playerDieText")

func GetAliveZombies():
	return Zombies.get_child_count()

func _on_Zombie_Spawn_Timer_timeout():
	if not Player.IsAlive():
		return
	createZombies(1)
	timer.start(2)

func _input(event):
	if not Player.IsAlive():
		return
	if event.is_action_pressed("ui_esc"):
		paused = not paused
	if paused:
		change_center_text()
		pause_all_timers()
	else:
		change_center_text("")
		pause_all_timers()

func pause_all_timers():
	$Zombie_Spawn_Timer.set_paused(paused)
	for zTime in Zombies.get_children():
		if zTime.has_method("toogle_fade_timer"):
			zTime.toogle_fade_timer()

func change_center_text(new_text = "Game Paused", color = Vector3(1, 1, 1), color_a = 1):
	textDisplay.text = new_text
	textDisplay.self_modulate.r = color.x
	textDisplay.self_modulate.g = color.y
	textDisplay.self_modulate.b = color.z
	textDisplay.self_modulate.a = color_a

func playerDieText():
	change_center_text("Game Over", Vector3(1, 0, 0))
