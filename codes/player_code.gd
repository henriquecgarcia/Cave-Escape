extends KinematicBody2D

var isDead = false

var health = 100
var SPEED = 200
var velocity = Vector2()
var lastShoot = Time
var projectile = preload("res://codes/Bullet.tscn")

var bNode
func _ready():
	var kids = get_parent().get_children()
	for kid in kids:
		if kid.get_name() == "Bullets":
			bNode = kid
			break

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		velocity.x = -SPEED
	elif Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		velocity.x =  SPEED
		
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		velocity.y = -SPEED
	elif Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		velocity.y = SPEED

	if Input.is_key_pressed(KEY_SPACE):
		shoot()

func shoot():
	if not bNode: # should not be happening.
		return
	var b = projectile.instance()
	b.start($Gun.global_position, rotation)
	bNode.add_child(b)

func _physics_process(delta):
	if isDead:
		return
	get_input()
	var dir = get_global_mouse_position()
	# Don't move if too close to the mouse pointer.
	rotation = global_position.angle_to_point( dir ) - PI # dir.angle_to( global_position )
	
	move_and_slide(velocity, Vector2(0, -1))

func Kill():
	isDead = true
	print("PLAYER DIED!")
	$Collision_Braco_D.free()
	$Collision_Head.free()
	$Collision_Braco_E.free()
	$Collision_Maos.free()

func IsAlive():
	return not isDead

func DoDamage(dmg):
	print("[PLAYER] Damage taken:  ", dmg)
	health -= dmg
	if health <= 0:
		print("Kill()")
		Kill()
