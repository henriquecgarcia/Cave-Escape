extends KinematicBody2D

const DAMAGE = 50

var SPEED = 750
var velocity = Vector2()

func start(pos, dir):
	rotation = dir
	position = pos
	velocity = Vector2(SPEED, 0).rotated(rotation)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.collider.has_method("DoDamage"):
			collision.collider.DoDamage(DAMAGE)
		if collision.collider:
			queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
