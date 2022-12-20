extends KinematicBody2D

const SPEED = 40
const DAMAGE = 1

var health = 100
var velocity = Vector2()
var lastShoot = Time
var change_anim = true

var path = []
var nav = null setget set_nav

var isDead = false
var first = true
var player
var collider

func _ready():
	scale = Vector2(0.5, 0.5)
	$Model.animation = "idle"

func set_nav(new_nav):
	nav = new_nav
	update_path()

func update_path():
	if not player:
		return
	if not player.IsAlive():
		return
	
	if player.IsPoused():
		return
	if not nav:
		return
	path = nav.get_simple_path(position, player.position, false)
	
	var ang = lerp_angle($Model.global_rotation, position.angle_to_point( path[0] ) - PI, 0.1)
	$Model.rotation = ang

func _on_Recalculate_Route_timeout():
	update_path()

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
	var ang = 0
	
	
	if path.size() > 0:
		var d = position.distance_to(path[0])
		if d > 2:
			ang = lerp_angle($Model.global_rotation, nav.get_angle_to(velocity)-PI, 0.1) #position.angle_to_point( path[0] ) - PI
			set_position(position.linear_interpolate(path[0], (SPEED * delta)/d))
		else:
			path.remove(0)
	else:
		ang = position.angle_to_point( plpos ) - PI
		velocity.x = SPEED*cos(ang)
		velocity.y = SPEED*sin(ang)
	
	if change_anim:
		$Model.animation = "move"
	
	#$Model.set_rotation(ang)
	var collision = move_and_collide(velocity)
	if collision:
		if collision.collider.has_method("DoDamage"):
			if change_anim:
				$Model.animation = "attack"
				change_anim = false
				collider = collision.collider
	else:
		collider = null


func Kill():
	$Model.playing = false
	$Collision.free()
	$Hurtbox.free()
	$VisionArea.free()
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
		return
	first = false
	$Timer.start(3)


func _on_VisionArea_area_entered(area):
	player = area.get_parent()
	update_path()


func _on_Model_animation_finished():
	if $Model.animation == "attack":
		change_anim = true
		if collider:
			collider.DoDamage(DAMAGE)
