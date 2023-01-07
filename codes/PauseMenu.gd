extends Control

onready var btn = $TextureButton
#onready var btn = $Button

var main = null

func _ready():
	main = get_tree()
	visible = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_esc"):
		get_tree().paused = not get_tree().paused
	if get_tree().paused:
		visible = true
	else:
		visible = false
