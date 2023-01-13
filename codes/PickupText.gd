extends Label

onready var timer = $Timer

var first = true

func _ready():
	rect_size *= 2
	rect_scale = Vector2(0.5, 0.5)

func _process(_delta):
	if first:
		return
	self_modulate.a = timer.time_left/1

func SetPickupText(txt):
	text = txt
	timer.start(2)

func _on_Timer_timeout():
	if first:
		first = false
		timer.start(1)
	else:
		queue_free()
