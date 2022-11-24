extends KinematicBody2D

var isDead = false
const SPEED = 200
var paused = false

var health = 100
var velocity = Vector2()
var lastShoot = Time.get_ticks_msec()
var projectile = preload("res://codes/Bullet.tscn")

var bNode
func _ready():
	PlayerStats.connect("no_health", self, "Kill")
	scale = Vector2(0.5, 0.5)
	var kids = get_parent().get_children()
	for kid in kids:
		if kid.get_name() == "Bullets":
			bNode = kid
			break

func get_input():
	if Input.is_key_pressed(KEY_ESCAPE):
		paused = not paused
	
	if paused:
		return

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

func _physics_process(delta):
	if isDead:
		return
	get_input()
	if paused:
		return
	var dir = get_global_mouse_position()
	
	rotation = global_position.angle_to_point( dir ) - PI
	move_and_slide(velocity, Vector2(0, -1))

func Kill():
	isDead = true
	print("PLAYER DIED!")
	$Collision_Main.free()
	$Hurtbox/CollisionShape2D.free()

func IsAlive():
	return not isDead

func IsPoused():
	return paused

func DoDamage(dmg):
	print("[PLAYER] Damage taken:  ", dmg)
	health -= dmg
	PlayerStats.health = health


func _on_Hurtbox_area_entered(area):
	DoDamage(1)
