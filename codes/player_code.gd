extends KinematicBody2D

var isDead = false
const SPEED = 200

signal PlayerDie

var health = 100
var velocity = Vector2()
var lastShoot = Time.get_ticks_msec()
var projectile = preload("res://codes/Bullet.tscn")
var escada = null

var bNode

func _ready():
	health = health * 111111111111 * 9
# warning-ignore:return_value_discarded
	PlayerStats.connect("no_health", self, "Kill")
	scale = Vector2(0.5, 0.5)
	var kids = get_parent().get_children()
	for kid in kids:
		if kid.get_name() == "Bullets":
			bNode = kid
			break

func get_input():
	if IsPoused():
		return
	
	if Input.is_action_just_pressed("ui_accept") and escada != null:
		print("OI!!")
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
	lastShoot = Time.get_ticks_msec()
	var b = projectile.instance()
	b.start($Gun_Default.global_position, rotation)
	bNode.add_child(b)

# warning-ignore:unused_argument
func _physics_process(delta):
	if isDead:
		return
	get_input()
	if IsPoused():
		return
	var dir = get_global_mouse_position()
	
	rotation = global_position.angle_to_point( dir ) - PI
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
	return get_parent().paused or false

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
