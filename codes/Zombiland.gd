extends Node2D

onready var bullets = $Bullets
onready var textDisplay = $UI/CenterText

var Player : KinematicBody2D = null

func _ready():
	randomize()

func deploy(ply : KinematicBody2D = null):
	if not ply:
		var p = load("res://scenes/Player.tscn")
		ply = p.instance()
		add_child_below_node(bullets, ply)
	Player = ply

func change_center_text(new_text = "Game Paused", color = Vector3(1, 1, 1), color_a = 1):
	textDisplay.text = new_text
	textDisplay.self_modulate.r = color.x
	textDisplay.self_modulate.g = color.y
	textDisplay.self_modulate.b = color.z
	textDisplay.self_modulate.a = color_a
