extends Control

onready var start_button = $pl/GridContainer/Start_button
onready var quit_button = $pl/GridContainer/Quit_button
onready var pl = $pl
onready var nav = $Nav
onready var walls = $Nav/Map
const MainMenu := true

var EscadaUp
var eCode = preload("res://scenes/Escada.tscn")
var borders = Rect2(1, 1, 999, 999)
var path
var map = []

func reload_path():
	var walker = Walker.new(Vector2(5, 5), borders)
	map = walker.walk(200)
	
	var lastRoom = walker.get_end_room()
	EscadaUp.position = lastRoom.position * 32
	
	pl.position = map.front()*32
	
	walker.queue_free()
	for p in map:
		walls.set_cellv(p, 1)
	walls.update_bitmask_region(borders.position, borders.end)
	
	path = nav.get_simple_path(pl.position, EscadaUp.position, false)

func _ready():
	var stair = eCode.instance()
	add_child_below_node(nav, stair)
	EscadaUp = stair
	reload_path()

func _physics_process(delta):
	if !path.empty():
		var next_point = path[0]
		pl.arms.look_at(next_point)
		pl.feet.look_at(next_point)
		pl.set_arms_animation("run")
		pl.set_feet_animation("run")
		var distance_to_next_point = pl.position.distance_to(next_point)
		if distance_to_next_point < 2:
			path.remove(0)
		else:
			pl.set_position(pl.position.linear_interpolate(next_point, (90 * delta)/distance_to_next_point))
	else:
		path = nav.get_simple_path(pl.position, EscadaUp.position, false)
		var next_point = EscadaUp.position
		pl.arms.look_at(next_point)
		pl.feet.look_at(next_point)
		pl.set_arms_animation()
		pl.set_feet_animation()
	if pl.position == EscadaUp.position:
		for p in map:
			walls.set_cellv(p, 0)
		walls.update_bitmask_region(borders.position, borders.end)
		reload_path()
		return

func _on_Start_button_button_down():
	start_button.rect_scale *= 1.75

func _on_Start_button_button_up():
	start_button.rect_scale /= 1.75
	if get_tree().change_scene("res://scenes/LoadingScene.tscn"):
		get_tree().quit()
	else:
		var _main_scene = load("res://scenes/Cave_Main.tscn")

func _on_main_scene_loaded():
	# Quando a cena principal for carregada, troque para ela
	if get_tree().change_scene("res://scenes/Cave_Main.tscn"):
		get_tree().quit()

func _on_Quit_button_button_down():
	quit_button.rect_scale *= 1.75

func _on_Quit_button_button_up():
	quit_button.rect_scale /= 1.75
	get_tree().quit()

########################################################################

onready var sound_btn = $pl/GridContainer/GridContainer/SoundMute
const muted_press = preload("res://image/menu/som_muted_pressed.png")
const muted = preload("res://image/menu/som_muted.png")
const som_press = preload("res://image/menu/som_pressed.png")
const som = preload("res://image/menu/som.png")

var muteStats = not Settings.Sounds

func _on_SoundMute_button_down():
	sound_btn.rect_scale *= 1.75

func _on_SoundMute_button_up():
	sound_btn.rect_scale /= 1.75
	Settings.Sounds = muteStats
	muteStats = not muteStats
	if muteStats:
		sound_btn.texture_normal = muted
		sound_btn.texture_pressed = muted_press
	else:
		sound_btn.texture_normal = som
		sound_btn.texture_pressed = som_press

onready var music_btn = $pl/GridContainer/GridContainer/MusicMute
const mmuted = preload("res://image/menu/musica_muted.png")
const mmuted_press = preload("res://image/menu/musica_muted_pressed.png")
const music = preload("res://image/menu/music.png")
const music_press = preload("res://image/menu/musica_pressed.png")

var bgStats = not Settings.Background

func _on_MusicMute_button_down():
	music_btn.rect_scale *= 1.75

func _on_MusicMute_button_up():
	music_btn.rect_scale /= 1.75
	Settings.Background = bgStats
	bgStats = not bgStats
	if bgStats:
		music_btn.texture_normal = mmuted
		music_btn.texture_pressed = mmuted_press
	else:
		music_btn.texture_normal = music
		music_btn.texture_pressed = music_press
