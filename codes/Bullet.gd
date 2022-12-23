extends KinematicBody2D

const DAMAGE = 50

var SPEED = 750/2
var velocity = Vector2()
var creator = null

func start(pos, dir, player : KinematicBody2D = null):
	scale = Vector2(.5, .5)
	rotation = dir
	position = pos
	velocity = Vector2(SPEED, 0).rotated(rotation)
	creator = player

func _physics_process(delta):
	if creator.IsPaused():
		return
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider:
			queue_free()
			if collision.collider.has_method("DoDamage"):
				collision.collider.DoDamage(DAMAGE, creator)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
