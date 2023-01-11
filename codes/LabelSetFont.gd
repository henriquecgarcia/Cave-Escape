extends ColorRect

onready var label = $Label

func _ready():
	var font = DynamicFont.new()
	font.font_data = load("res://fonts/Roboto-Regular.ttf")
	font.size = 96
	label.add_font_override("font", font)
	label.rect_size *= 2
	label.rect_scale = Vector2(0.5, 0.5)
