extends Control

onready var _bg = $Background
onready var _ammo = $AmmoText

var current_ammo = 1 setget set_ammo
var max_ammo = 1 setget set_max_ammo

func set_ammo(value):
	current_ammo = clamp(value, 0, max_ammo)
	_bg.value = current_ammo
	_ammo.text = str(current_ammo)

func set_max_ammo(value):
	max_ammo = max(value, 1)
	self.current_ammo = min(current_ammo, max_ammo)
	_bg.max_value = max_ammo

# Called when the node enters the scene tree for the first time.
func _ready():
	self.max_ammo = PlayerStats.max_ammo
	self.current_ammo = PlayerStats.ammo
	# warning-ignore:return_value_discarded
	PlayerStats.connect("ammo_changed", self, "set_ammo")
	# warning-ignore:return_value_discarded
	PlayerStats.connect("max_ammo_changed", self, "set_max_ammo")
	
	_bg.rect_size = _bg.rect_size * 2
	_bg.rect_scale = Vector2(0.5, 0.5)
	
	_bg.self_modulate.r = 0.5
	_bg.self_modulate.g = 0.5
	_bg.self_modulate.b = 0.5
	
	var font = DynamicFont.new()
	font.font_data = load("res://fonts/zombie_blood.ttf")
	font.size = 96
	_ammo.add_font_override("font", font)
	_ammo.rect_size = _ammo.rect_size * 10
	_ammo.rect_scale = Vector2(0.1, 0.1)
