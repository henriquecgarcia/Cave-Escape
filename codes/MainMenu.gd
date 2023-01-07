extends Control

onready var start_button = $GridContainer/Start_button
onready var quit_button = $GridContainer/Quit_button

func _ready():
	pass # Replace with function body.

func _on_Start_button_button_down():
	start_button.rect_scale *= 1.75

func _on_Start_button_button_up():
	start_button.rect_scale /= 1.75
	if get_tree().change_scene("res://scenes/Cave_Main.tscn"):
		get_tree().quit()

func _on_Quit_button_button_down():
	quit_button.rect_scale *= 1.75

func _on_Quit_button_button_up():
	quit_button.rect_scale /= 1.75
	get_tree().quit()

########################################################################

onready var sound_btn = $GridContainer/GridContainer/SoundMute
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

onready var music_btn = $GridContainer/GridContainer/MusicMute
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
