extends Control

var health = 100 setget set_health
var max_health = 100 setget set_max_health
onready var rect = $HealthBar
onready var text = $HealthText

func set_health(value):
	health = clamp(value, 0, max_health)
	rect.value = health
	text.text = str(health)

func set_max_health(value):
	max_health = max(1, value)
	rect.set_max(max_health)

func _ready():
	self.max_health = PlayerStats.max_health
	self.health = PlayerStats.health
	# warning-ignore:return_value_discarded
	PlayerStats.connect("health_changed", self, "set_health")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_health")
	
	rect.rect_size = rect_size * 2
	rect.rect_scale = Vector2(0.5, 0.5)
	
	rect.self_modulate.r = 1
	rect.self_modulate.g = 0
	rect.self_modulate.b = 0
	
	var font = DynamicFont.new()
	font.font_data = load("res://fonts/zombie_blood.ttf")
	font.size = 96
	text.add_font_override("font", font)
	text.rect_size = text.rect_size * 10
	text.rect_scale = Vector2(0.1, 0.1)
