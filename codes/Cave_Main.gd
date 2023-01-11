extends Node2D

onready var player = $Player

const maxLevels : int = 5

var current_sublevel : int = maxLevels

var subLevel = preload("res://scenes/Cave_Sublevel.tscn")
var exit = preload("res://scenes/Cave_Exit.tscn")
var Zombieland = preload("res://scenes/Zombiland.tscn")
var lvl_hist = []
var current_level

func _ready():
	var lvl = subLevel.instance()
	add_child_below_node($Hold, lvl)
	lvl.start()
	lvl_hist.append({level = current_sublevel, map = lvl.current_map})
	lvl.EscadaDown.queue_free()
	current_level = lvl

func change_level(new_level := current_sublevel):
	var cave = current_level
	cave.queue_free()
	
	var lvl = subLevel.instance()
	add_child_below_node($Hold, lvl)
	
	var index = maxLevels-new_level
	if index in range(lvl_hist.size()):
		lvl.start(lvl_hist[index].map)
	else:
		lvl.start()
		lvl_hist.append({level = new_level, map = lvl.current_map})
	
	if new_level == 1:
		var pos = lvl.EscadaUp.position
		lvl.EscadaUp.queue_free()
		var ex = exit.instance()
		ex.position = pos
		lvl.add_child_below_node(lvl.walls, ex)
	current_sublevel = new_level
	current_level = lvl

func sublevelup():
	return change_level(current_sublevel-1)

func subleveldown():
	var ret = change_level(current_sublevel+1)
	var lvl = current_level
	player.position = lvl.Escada.position
	if current_sublevel == maxLevels:
		lvl.EscadaDown.queue_free()
	return ret

func exit_cave():
	var cave = current_level
	cave.queue_free()
	
	var final = Zombieland.instance
	add_child_below_node($Hold, final)
	final.Deploy(player)
	current_level = final

func change_center_text(new_text = "Game Paused", color = Vector3(1, 1, 1), color_a = 1):
	current_level.change_center_text(new_text, color, color_a)

func playerDieText():
	change_center_text("Game Over", Vector3(1, 0, 0))
