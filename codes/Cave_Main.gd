extends Node2D

onready var player = $Player

const maxLevels = 5

var current_sublevel = 5
var subLevel = preload("res://scenes/Cave_Sublevel.tscn")
var exit = preload("res://scenes/Cave_Exit.tscn")
var lvl_hist = []
var current_level

func _ready():
	var lvl = subLevel.instance()
	add_child_below_node($Hold, lvl)
	lvl.start()
	lvl_hist.append({level = current_sublevel, map = lvl.current_map})
	current_level = lvl

func change_level(new_level):
	var cave = current_level
	cave.queue_free()
	
	var lvl = subLevel.instance()
	add_child_below_node($Hold, lvl)
	
	var index = maxLevels-new_level
	if range(lvl_hist.size()).has(index):
		lvl.start(lvl_hist[index].map)
	else:
		lvl.start()
		lvl_hist.append({level = new_level, map = lvl.current_map})
	
	if new_level == 1:
		var pos = lvl.Escada.position
		lvl.Escada.queue_free()
		var ex = exit.instance()
		ex.position = pos
		lvl.add_child_below_node(lvl.walls, ex)
	current_sublevel = new_level
	current_level = lvl

func sublevelup():
	return change_level(current_sublevel-1)

func _input(_event):
	if not player.IsAlive():
		return
	
	if get_tree().paused:
		change_center_text()
		pause_all_timers()
	else:
		change_center_text("")
		pause_all_timers()

func pause_all_timers():
	current_level.pause_all_timers()

func change_center_text(new_text = "Game Paused", color = Vector3(1, 1, 1), color_a = 1):
	current_level.change_center_text(new_text, color, color_a)

func playerDieText():
	change_center_text("Game Over", Vector3(1, 0, 0))
