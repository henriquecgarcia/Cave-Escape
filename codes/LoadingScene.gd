extends Node2D

var load_progress = 0

onready var text = $Label

func _ready():
	var font = DynamicFont.new()
	font.font_data = load("res://fonts/zombie_blood.ttf")
	font.size = 96
	text.add_font_override("font", font)
	text.self_modulate.r = 1
	text.self_modulate.g = 0
	text.self_modulate.b = 0
	text.rect_size *= 3
	text.rect_scale /= 3

func _process(delta):
	# Atualize o progresso de carregamento
	load_progress += delta * 100
	text.text = "Carregando: " + str(int(load_progress)) + "%"
	
	# Quando o progresso chegar a 100%, troque para a cena principal
	if load_progress >= 100:
		if get_tree().change_scene("res://scenes/Cave_Main.tscn"):
			get_tree().quit()
