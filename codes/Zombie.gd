extends KinematicBody2D

const SPEED = 1
const DAMAGE = 1

var health = 100
var velocity = Vector2()
var lastShoot = Time
var isDead = false
var player

func _physics_process(delta):
	if isDead:
		return
	var kids = get_tree().get_root().get_child(0).get_children()
	if not player:
			for kid in kids:
				if kid.get_name() == "Player":
					player = kid
	
	if not player:
		return
	if not player.IsAlive():
		return
	var plpos = player.get_position()
	
	var ang = global_position.angle_to_point( plpos ) - PI
	velocity.x = SPEED*cos(ang)
	velocity.y = SPEED*sin(ang)
	
	set_rotation(ang)
	# We don't need to multiply velocity by delta because "move_and_slide" already takes delta time into account.

	# The second parameter of "move_and_slide" is the normal pointing up.
	# In the case of a 2D platformer, in Godot, upward is negative y, which translates to -1 as a normal.
	var collision = move_and_collide(velocity)
	if collision:
		if collision.collider.has_method("DoDamage"):
			collision.collider.DoDamage(DAMAGE)


func Kill():
	$Collision.free()
	isDead = true
	$Timer.start(.8)

func IsAlive():
	return not isDead

func DoDamage(dmg):
	print("[ZOMBIE] Damage taken! ", dmg)
	health -= dmg
	if health <= 0:
		Kill()

func _on_Timer_timeout():
	$Model.modulate.a = ($Model.modulate.a)/2
	if $Model.modulate.a > 0.1:
		$Timer.start(.8)
	else:
		queue_free()
