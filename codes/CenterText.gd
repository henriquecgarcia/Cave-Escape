extends Label

func _ready():
	var font = DynamicFont.new()
	font.font_data = load("res://fonts/zombie_blood.ttf")
	font.size = 96
	add_font_override("font", font)
	self_modulate.r = 1
	self_modulate.g = 0
	self_modulate.b = 0
	rect_size = rect_size * 3
	rect_scale = rect_scale / 3
