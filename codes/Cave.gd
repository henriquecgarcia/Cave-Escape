extends Node2D

onready var rng = RandomNumberGenerator.new()
onready var Zombies = $Zombie
onready var walls = $Nav/Walls
onready var textDisplay = $UI/CenterText
onready var pickDisplay = $UI/PickupTextArea
onready var nav = $Nav
const MainMenu := false

var paused = false
var borders = Rect2(1, 1, 999, 999)
var current_map = []
var player
var EscadaUp
var EscadaDown

var walker

var pCode = preload("res://scenes/Player.tscn")
var zCode = preload("res://scenes/Zombie.tscn")
var eCode = preload("res://scenes/Escada.tscn")
var dCode = preload("res://scenes/Escada_Desce.tscn")
var Map

func _ready():
	randomize()

func start(map = []):
	walker = Walker.new(Vector2(5, 5), borders)
	if len(map) < 50:
		map = walker.walk(200)
	current_map = map.duplicate()
	
	var lastRoom = walker.get_end_room()
	var stair = eCode.instance()
	add_child_below_node(nav, stair)
	stair.position = lastRoom.position * 32
	EscadaUp = stair
	
	if get_parent().player:
		player = get_parent().player
	else:
		var ply = pCode.instance()
		add_child(ply)
		player = $Player
	
	player.position = map.front()*32
	player.connect("PlayerDie", self, "playerDieText")
	
	var stair2 = dCode.instance()
	add_child_below_node(EscadaUp, stair2)
	stair2.position = player.position
	EscadaDown = stair2
	
	var spawnedZombiesPos = []
	for room in walker.rooms:
		if room == lastRoom or player.position.distance_to(room.position) <= 30:
			continue
		
		var pos = room.position
		var size = room.tamanho
		var rzc = 0 ## Room Zombie COUNT
		var top_left_corner = (pos - size/2).ceil()
		
		while rzc < get_zombies_in_room(room):
			var p = top_left_corner + Vector2( randi() % int(size.x), randi() % int(size.y) )
			if position.distance_to(p * 32) < 300:
				continue
			
			var zombie = zCode.instance()
			zombie.position = p * 32 + Vector2(16, 16)
			Zombies.add_child(zombie)
			zombie.nav = nav
			zombie.connect("ZombieDie", self, "ZombieKilled")
			
			if not (room.position in map) or (zombie.position in spawnedZombiesPos):
				zombie.free()
				continue
			
			spawnedZombiesPos.append(zombie.position)
			rzc += 1
	
	walker.queue_free()
	for p in map:
		walls.set_cellv(p, 1)
	walls.update_bitmask_region(borders.position, borders.end)

func get_zombies_in_room(room : Dictionary = {}) -> float:
	if not room.has("tamanho"):
		return 0.0
	var size = room.tamanho
	return ceil( ceil(sqrt( (size.x * size.x) + (size.y * size.y) ))/3)

func GetAliveZombies():
	return Zombies.get_child_count()

func ZombieKilled(killer):
	if killer == player:
		player.KilledZombie()

func pause_all_timers():
	for zTime in Zombies.get_children():
		if zTime.has_method("toogle_fade_timer"):
			zTime.toogle_fade_timer()

func pause_anims():
	for zTime in Zombies.get_children():
		zTime.toogle_anim()
	
	player.toogle_anim()

func change_center_text(new_text = "Game Paused", color = Vector3(1, 1, 1), color_a = 1):
	textDisplay.text = new_text
	textDisplay.self_modulate.r = color.x
	textDisplay.self_modulate.g = color.y
	textDisplay.self_modulate.b = color.z
	textDisplay.self_modulate.a = color_a

func playerDieText():
	change_center_text("Game Over", Vector3(1, 0, 0))

func set_center_text(txt):
	pickDisplay.SetPickupText(txt)
