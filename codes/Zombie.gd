extends KinematicBody2D

const SPEED = 1
const DAMAGE = 1

var health = 100
var velocity = Vector2()
var lastShoot = Time
var isDead = false
var first = true
var player

func _ready():
	scale = Vector2(0.5, 0.5)

# warning-ignore:unused_argument
func _physics_process(delta):
	if isDead:
		if first:
			return
		$Model.modulate.a = $Timer.time_left/3
		return
	
	if not player:
		return
	if not player.IsAlive():
		return
	
	if player.IsPoused():
		return

	var plpos = player.get_position()
	
	var ang = global_position.angle_to_point( plpos ) - PI
	velocity.x = SPEED*cos(ang)
	velocity.y = SPEED*sin(ang)
	
	set_rotation(ang)
	
	var collision = move_and_collide(velocity)
	if collision:
		if collision.collider.has_method("DoDamage"):
			collision.collider.DoDamage(DAMAGE)


func Kill():
	$Collision.free()
	$Hurtbox.free()
	isDead = true
	$Timer.start(1)

func toogle_fade_timer():
	if not isDead:
		return
	$Timer.paused = not $Timer.paused

func IsAlive():
	return not isDead

func DoDamage(dmg):
	if player:
		if player.IsPoused():
			return
	print("[ZOMBIE] Damage taken! ", dmg)
	health -= dmg
	if health <= 0:
		Kill()

func _on_Timer_timeout():
	if not first:
		queue_free()
	first = false
	$Timer.start(3)


func _on_VisionArea_area_entered(area):
	player = area.get_parent()
