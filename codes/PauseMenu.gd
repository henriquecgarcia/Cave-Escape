extends Control

#onready var btn = $Button

func _ready():
	visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_esc"):
		get_tree().paused = not get_tree().paused
	if get_tree().paused:
		visible = true
	else:
		visible = false

onready var resume = $Center/Resume
onready var quit = $Center/Quit

func _on_Resume_button_down():
	resume.rect_scale *= 1.75

func _on_Resume_button_up():
	resume.rect_scale /= 1.75
	visible = false
	get_tree().paused = false

func _on_Quit_button_down():
	quit.rect_scale *= 1.75

func _on_Quit_button_up():
	quit.rect_scale /= 1.75
	get_tree().quit()

#########################################################################
onready var home = $Center/GridContainer/Home

func _on_Home_button_down():
	home.rect_scale *= 1.75

func _on_Home_button_up():
	home.rect_scale /= 1.75
	get_tree().paused = false
	if get_tree().change_scene("res://scenes/MainMenu.tscn"):
		get_tree().quit()

onready var sound_btn = $Center/GridContainer/Som
const muted_press = preload("res://image/menu/som_muted_pressed.png")
const muted = preload("res://image/menu/som_muted.png")
const som_press = preload("res://image/menu/som_pressed.png")
const som = preload("res://image/menu/som.png")

var muteStats = not Settings.Sounds

func _on_Som_button_down():
	sound_btn.rect_scale *= 1.75

func _on_Som_button_up():
	sound_btn.rect_scale /= 1.75
	Settings.Sounds = muteStats
	muteStats = not muteStats
	if muteStats:
		sound_btn.texture_normal = muted
		sound_btn.texture_pressed = muted_press
	else:
		sound_btn.texture_normal = som
		sound_btn.texture_pressed = som_press

onready var music_btn = $Center/GridContainer/Musica
const mmuted = preload("res://image/menu/musica_muted.png")
const mmuted_press = preload("res://image/menu/musica_muted_pressed.png")
const music = preload("res://image/menu/music.png")
const music_press = preload("res://image/menu/musica_pressed.png")

var bgStats = not Settings.Background

func _on_Musica_button_down():
	music_btn.rect_scale *= 1.75

func _on_Musica_button_up():
	music_btn.rect_scale /= 1.75
	Settings.Background = bgStats
	bgStats = not bgStats
	if bgStats:
		music_btn.texture_normal = mmuted
		music_btn.texture_pressed = mmuted_press
	else:
		music_btn.texture_normal = music
		music_btn.texture_pressed = music_press
