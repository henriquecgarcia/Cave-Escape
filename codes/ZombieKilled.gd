extends Control

onready var _bg = $Background
onready var _kc = $KillCount
onready var _nw = $NextWep

var kills = 0 setget set_kills
var next_wep = ""
var wep_kill = 0

func set_kills(val):
	kills = max(0, val)
	_kc.text = str(kills)+" kills"

func set_next_weapon(wep : String , kill : int):
	kill += kills
	next_wep = wep
	_nw.text = next_wep + " (" + str(kill) + ")"

func _ready():
	self.kills = PlayerStats.kills
	
	# warning-ignore:return_value_discarded
	PlayerStats.connect("kills_changed", self, "set_kills")
	
	_bg.rect_size = _bg.rect_size * 2
	_bg.rect_scale = Vector2(0.5, 0.5)
	_bg.color.r = 0.5
	_bg.color.g = 0.5
	_bg.color.b = 0.5
	
	var font = DynamicFont.new()
	font.font_data = load("res://fonts/zombie_blood.ttf")
	font.size = 96
	_kc.add_font_override("font", font)
	_kc.rect_size *=  10
	_kc.rect_scale = Vector2(0.1, 0.1)
	
	_nw.add_font_override("font", font)
	_nw.rect_size *=  10
	_nw.rect_scale = Vector2(0.1, 0.1)
