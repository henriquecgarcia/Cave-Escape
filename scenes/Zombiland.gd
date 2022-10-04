extends Node2D

var Zombies
var curZombies
var zCode = preload("res://codes/Zombie.tscn")

func createZombies(amount = 1):
	for i in amount:
		var b = zCode.instance()
		#b.position = Vector2(randomize(), randomize())

# Called when the node enters the scene tree for the first time.
func _ready():
	var kids = get_children()
	for kid in kids:
		if kid.get_name() == "Zombies":
			Zombies = kid
			break
	
	#
