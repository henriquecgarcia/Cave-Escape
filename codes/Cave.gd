extends Node2D

onready var rng = RandomNumberGenerator.new()
onready var Zombies = $Zombie
onready var walls = $Walls
onready var textDisplay = $UI/CenterText

var paused = false
var borders = Rect2(1, 1, 999, 999)
var current_map = []
var player
var escada

var walker

var pCode = preload("res://scenes/Player.tscn")
var zCode = preload("res://scenes/Zombie.tscn")
var eCode = preload("res://scenes/Escada.tscn")

func _ready():
	randomize()

func start(map = []):
	walker = Walker.new(Vector2(2, 2), borders)
	if len(map) < 100:
		map = walker.walk(500)
	current_map = map.duplicate()
	
	var lastRoom = walker.get_end_room()
	var stair = eCode.instance()
	add_child_below_node(walls, stair)
	stair.position = lastRoom.position * 32
	
	if get_parent().player:
		player = get_parent().player
	else:
		var ply = pCode.instance()
		add_child(ply)
		player = $Player
	
	player.position = map.front()*32
	
	var spawnedZombiesPos = []
	for room in walker.rooms:
		if room == lastRoom or player.position.distance_to(room.position) <= 30:
			continue
		var zombie = zCode.instance()
		zombie.position = room.position*32
		Zombies.add_child(zombie)
		if not (room.position in map) or (zombie.position in spawnedZombiesPos):
			zombie.free()
			continue
		spawnedZombiesPos.append(zombie.position)
	
	walker.queue_free()
	for p in map:
		walls.set_cellv(p, -1)
	walls.update_bitmask_region(borders.position, borders.end)


func GetAliveZombies():
	return Zombies.get_child_count()

func _input(event):
	if not player.IsAlive():
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
