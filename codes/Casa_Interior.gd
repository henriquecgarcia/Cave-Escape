extends Node2D

onready var rng = RandomNumberGenerator.new()
onready var Zombies = $Zombie
onready var walls = $Walls
onready var textDisplay = $UI/CenterText

var paused = false
var borders = Rect2(1, 1, 999, 999)
var pCode = preload("res://scenes/Player.tscn")
var zCode = preload("res://scenes/Zombie.tscn")

func _ready():
	randomize()
	var walker = Walker.new(Vector2(2, 2), borders)
	var map = walker.walk(500)
	
	var player = pCode.instance()
	add_child(player)
	player.position = map.front()*32
	
	var lastRoom = walker.get_end_room()
	
	for room in walker.rooms:
		if room == lastRoom or player.position.distance_to(room.position) <= 3:
			continue
		var zombie = zCode.instance()
		zombie.position = room.position*32
		Zombies.add_child(zombie)
	
	walker.queue_free()
	for p in map:
		walls.set_cellv(p, -1)
	walls.update_bitmask_region(borders.position, borders.end)
	
	#textDisplay = ""

func GetAliveZombies():
	return Zombies.get_child_count()

func _input(event):
	if event.is_action_pressed("ui_esc"):
		paused = true

