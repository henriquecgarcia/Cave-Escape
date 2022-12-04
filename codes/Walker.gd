extends Node
class_name Walker

const DIRECTIONS = [ Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN ]

var pos = Vector2.ZERO
var dir = Vector2.RIGHT
var border = Rect2()
var step_hist = []
var steps_since_turn = 0

func _init(sPos, new_border):
	assert(new_border.has_point( sPos ))
	pos = sPos
	step_hist.append(pos)
	border = new_border

func walk(steps):
	create_room(pos)
	for s in steps:
		if steps_since_turn >= 6:
			change_dir()

		if step():
			step_hist.append(pos)
		else:
			change_dir()
	return step_hist

func step():
	var target_position = pos + dir
	if border.has_point( target_position ):
		steps_since_turn += 1
		pos = target_position
		return true
	return false

func change_dir():
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(dir)
	directions.shuffle()
	dir = directions.pop_front()
	while not border.has_point(pos + dir):
		dir = directions.pop_front()
	create_room(pos)


func create_room(position):
	var size = Vector2(randi() % 4 + 2, randi() % 4 + 2 )
	var top_left_corner = (position - size/2).ceil()
	for y in size.y:
		for x in size.x:
			var new_step = top_left_corner + Vector2(x, y)
			if border.has_point(new_step):
				step_hist.append( new_step )
