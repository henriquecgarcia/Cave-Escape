extends KinematicBody2D

var isDead = false
const SPEED = 200
onready var arms = $Arms_Model
onready var feet = $Feet_Model

signal PlayerDie

var health = 100
var velocity = Vector2()
var lastShoot = Time.get_ticks_msec()
var projectile = preload("res://codes/Bullet.tscn")
var watchAnimations = ["handung_reload", "handgun_shoot", "rifle_reload", "rifle_shoot"]
var currentWeapon = "handgun"
var escada = null
var forceAnim = false

var bNode

func _ready():
	health = health * 111111111111 * 9
# warning-ignore:return_value_discarded
	PlayerStats.connect("no_health", self, "Kill")
	scale = Vector2(0.75, 0.75)
	var kids = get_parent().get_children()
	for kid in kids:
		if kid.get_name() == "Bullets":
			bNode = kid
			break
	set_arms_animation()
	set_feet_animation()

func set_arms_animation(newAnim = "idle"):
	newAnim = newAnim.to_lower()
	if not newAnim in [ "idle", "run", "reload", "shoot" ]:
		return
	if forceAnim:
		return
	if arms.animation != (currentWeapon+"_"+newAnim):
		arms.animation = currentWeapon+"_"+newAnim
		arms.frame = 0

func set_feet_animation(newAnim = "idle"):
	if not newAnim in [ "idle", "run", "strafe_left", "strafe_right" ]:
		return
	if feet.animation != newAnim:
		feet.animation = newAnim
		feet.frame = 0

func get_input():
	
	if Input.is_action_just_pressed("ui_accept") and escada != null:
		#print("OI!!")
		if get_parent().name == "Cave" :
			get_parent().sublevelup()
	
	velocity = Vector2()
	if Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
	elif Input.is_action_pressed("ui_right"):
		velocity.x =  SPEED
		
	if Input.is_action_pressed("ui_up"):
		velocity.y = -SPEED
	elif Input.is_action_pressed("ui_down"):
		velocity.y = SPEED

	if Input.is_key_pressed(KEY_SPACE) or Input.is_action_pressed("ui_mouse_click"):
		shoot()

func shoot():
	if not bNode: # should not be happening.
		return
	if lastShoot + 500 >= Time.get_ticks_msec():
		return # Only one shot per 0.5 seconds...
	set_arms_animation("shoot")
	forceAnim = true
	lastShoot = Time.get_ticks_msec()
	var b = projectile.instance()
	b.start($Gun_Default.global_position, rotation)
	bNode.add_child(b)

# warning-ignore:unused_argument
func _physics_process(delta):
	if isDead:
		return
	if IsPoused():
		return
	
	get_input()
	
	var dir = get_global_mouse_position()
	rotation = global_position.angle_to_point( dir ) - PI
	
	var changed = position
	
	if velocity != Vector2.ZERO:
		set_arms_animation("move")
		var rot = -(rotation_degrees + 180)
		var rot_deg_abs = abs(rot)
		print(rot)
		if rot_deg_abs <= 30:
			print("traz")
			if velocity.y > 0:
				set_feet_animation("strafe_right")
				changed = true
			elif velocity.y < 0:
				set_feet_animation("strafe_left")
				changed = true
		elif abs(rot_deg_abs - 180) <= 30:
			print("Frente")
			if velocity.y > 0:
				set_feet_animation("strafe_left")
				changed = true
			elif velocity.y < 0:
				set_feet_animation("strafe_right")
				changed = true
		elif abs(rot - 90) <= 30:
			print("baixo")
			if velocity.x > 0:
				set_feet_animation("strafe_left")
				changed = true
			elif velocity.x < 0:
				set_feet_animation("strafe_right")
				changed = true
		elif abs(rot_deg_abs - 90) <= 30:
			print("cima")
			if velocity.x > 0:
				set_feet_animation("strafe_right")
				changed = true
			elif velocity.x < 0:
				set_feet_animation("strafe_left")
				changed = true
		elif abs(rot - 45) <= 15:
			print("Pos 1")
			if velocity.x > 0 and velocity.y > 0:
				set_feet_animation("strafe_right")
				changed = true
			elif velocity.x < 0 and velocity.y < 0:
				set_feet_animation("strafe_left")
				changed = true
		elif abs(rot - 45*3) <= 15:
			print("pos 2")
			if velocity.x < 0 and velocity.y > 0:
				changed = true
				set_feet_animation("strafe_left")
			elif velocity.x > 0 and velocity.y < 0:
				changed = true
				set_feet_animation("strafe_right")
		elif abs(rot_deg_abs - 45*3) <= 15:
			print("Pos 3")
			if velocity.x > 0 and velocity.y > 0:
				changed = true
				set_feet_animation("strafe_left")
			elif velocity.x < 0 and velocity.y < 0:
				changed = true
				set_feet_animation("strafe_right")
		elif abs(rot_deg_abs - 45) <= 15:
			print("Pos 4")
			if velocity.x < 0 and velocity.y > 0:
				changed = true
				set_feet_animation("strafe_right")
			elif velocity.x > 0 and velocity.y < 0:
				changed = true
				set_feet_animation("strafe_left")
		else:
			set_feet_animation("move")

		if not changed:
			set_feet_animation("move")
	else:
		set_arms_animation()
		set_feet_animation()
	
	velocity = velocity.normalized() * SPEED
	
# warning-ignore:return_value_discarded
	move_and_slide(velocity, Vector2(0, -1))

func Kill():
	isDead = true
	print("PLAYER DIED!")
	$Collision_Main.free()
	$Hurtbox/CollisionShape2D.free()
	emit_signal("PlayerDie")

func IsAlive():
	return not isDead

func IsPoused():
	if get_parent().paused:
		return get_parent().paused or false
	return false

func DoDamage(dmg):
	print("[PLAYER] Damage taken:  ", dmg)
	health -= dmg
	PlayerStats.health = health

# warning-ignore:unused_argument
func _on_Hurtbox_area_entered(area):
	DoDamage(1)

func _on_Stair_Area_area_entered(area):
	escada = area

func _on_Stair_Area_area_exited(_area):
	escada = null


func _on_Arms_Model_animation_finished():
	if not arms.animation in watchAnimations:
		return
	forceAnim = false
	set_arms_animation()
