extends KinematicBody2D

var isDead = false

const SPEED = 200
const DEBUG = false
const weapons = {
	"handgun": {"ammo": 10, "damage": 25, "mags": 20},
	"rifle": {"ammo": 20, "damage": 50, "mags": 10},
	"shotgun": {"ammo": 5, "damage": 60, "mags": 10},
}

onready var arms = $Arms_Model
onready var feet = $Feet_Model
onready var _shoot_pos = $Arms_Model/Gun_Default
onready var _shoot = $Arms_Model/Gun_Default/Shoot_Sound
onready var _hurt = $Arms_Model/Hurt
onready var _bg_sound = $PlayerBG

signal PlayerDie

var weaponsPerKills = [
	[ "rifle", 75, Vector2.RIGHT * 9 ],
	[ "shotgun", 75*3, Vector2.RIGHT * 0 ]
]

var zombieKilled = 0
var health = 100
var velocity = Vector2()
var lastShoot = Time.get_ticks_msec()
var projectile = preload("res://codes/Bullet.tscn")
var watchAnimations = ["handgun_reload", "handgun_shoot", "rifle_reload", "rifle_shoot"]
var currentWeapon = "handgun"
var escada = null
var forceAnim = false
var current_ammo = weapons[ currentWeapon ].ammo

var bg_sounds = []
var cur_sounds = bg_sounds
var cur_sound = -1

var bNode

func _ready():
	randomize()
	if DEBUG:
		health = health * 111111111111 * 9
	
	# warning-ignore:return_value_discarded
	PlayerStats.connect("no_health", self, "Kill")
	PlayerStats.max_health = health
	PlayerStats.health = health
	
	PlayerStats.max_ammo = current_ammo
	PlayerStats.ammo = current_ammo
	
	for k in weapons.keys():
		var i = weapons[k]
		PlayerStats.add_weapon(k, i.ammo, i.mags, i.damage)
	
	var dir = Directory.new()
	dir.open("res://sounds/CaveBG/")
	dir.list_dir_begin()
	var file_name
	while true:
		file_name = dir.get_next()
		if file_name == "":
			break
		elif dir.current_is_dir():
			continue
		elif not file_name.ends_with(".mp3"):
			continue
		bg_sounds.append( load("res://sounds/CaveBG/" + file_name) )
	
	cur_sounds = bg_sounds.duplicate()
	cur_sounds.shuffle()
	_bg_sound.stream = cur_sounds.pop_front()
	_bg_sound.play()
	
	scale = Vector2(0.75, 0.75)
	
	bNode = get_parent().get_node("Bullets")
	
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
	
	if Input.is_key_pressed(KEY_R):
		var sound = load("res://sounds/weapon_reload.ogg")
		_shoot.stream = sound
		_shoot.play()
		
		set_arms_animation("reload")
		forceAnim = true
		
		current_ammo = weapons[ currentWeapon ].ammo
		PlayerStats.ammo = current_ammo
	elif Input.is_key_pressed(KEY_SPACE) or Input.is_action_pressed("ui_mouse_click"):
		shoot()

func shoot():
	if not bNode: # should not be happening.
		return
	if lastShoot + 500 >= Time.get_ticks_msec():
		return # Only one shot per 0.5 seconds...
	lastShoot = Time.get_ticks_msec()
	if current_ammo <= 0:
		var sound = load("res://sounds/weapon_no-ammo.ogg")
		_shoot.stream = sound
		_shoot.play()
		return
	set_arms_animation("shoot")
	forceAnim = true
	var b = projectile.instance()
	b.start(_shoot_pos.global_position, rotation, self, weapons[ currentWeapon ].damage)
	bNode.add_child(b)
	
	current_ammo -= 1
	
	PlayerStats.ammo = current_ammo
	
	var sound = load("res://sounds/" + currentWeapon + "_shot.mp3")
	if sound:
		_shoot.stream = sound
	_shoot.play()

func _physics_process(_delta):
	if isDead:
		return
	if IsPaused():
		return
	
	get_input()
	
	var dir = get_global_mouse_position()
	rotation = global_position.angle_to_point( dir ) - PI
	
	if velocity != Vector2.ZERO:
		var changed = false
		set_arms_animation("move")
		
		var rot = -(rotation_degrees + 180)
		var rot_deg_abs = abs(rot)
		if rot_deg_abs <= 30:
			if DEBUG:
				print("traz")
			if velocity.y > 0:
				set_feet_animation("strafe_right")
				changed = true
			elif velocity.y < 0:
				set_feet_animation("strafe_left")
				changed = true
		elif abs(rot_deg_abs - 180) <= 30:
			if DEBUG:
				print("Frente")
			if velocity.y > 0:
				set_feet_animation("strafe_left")
				changed = true
			elif velocity.y < 0:
				set_feet_animation("strafe_right")
				changed = true
		elif abs(rot - 90) <= 30:
			if DEBUG:
				print("baixo")
			if velocity.x > 0:
				set_feet_animation("strafe_left")
				changed = true
			elif velocity.x < 0:
				set_feet_animation("strafe_right")
				changed = true
		elif abs(rot_deg_abs - 90) <= 30:
			if DEBUG:
				print("cima")
			if velocity.x > 0:
				set_feet_animation("strafe_right")
				changed = true
			elif velocity.x < 0:
				set_feet_animation("strafe_left")
				changed = true
		elif abs(rot - 45) <= 15:
			if DEBUG:
				print("Pos 1")
			if velocity.x > 0 and velocity.y > 0:
				set_feet_animation("strafe_right")
				changed = true
			elif velocity.x < 0 and velocity.y < 0:
				set_feet_animation("strafe_left")
				changed = true
		elif abs(rot - 45*3) <= 15:
			if DEBUG:
				print("pos 2")
			if velocity.x < 0 and velocity.y > 0:
				changed = true
				set_feet_animation("strafe_left")
			elif velocity.x > 0 and velocity.y < 0:
				changed = true
				set_feet_animation("strafe_right")
		elif abs(rot_deg_abs - 45*3) <= 15:
			if DEBUG:
				print("Pos 3")
			if velocity.x > 0 and velocity.y > 0:
				changed = true
				set_feet_animation("strafe_left")
			elif velocity.x < 0 and velocity.y < 0:
				changed = true
				set_feet_animation("strafe_right")
		elif abs(rot_deg_abs - 45) <= 15:
			if DEBUG:
				print("Pos 4")
			if velocity.x < 0 and velocity.y > 0:
				changed = true
				set_feet_animation("strafe_right")
			elif velocity.x > 0 and velocity.y < 0:
				changed = true
				set_feet_animation("strafe_left")
		
		if not changed:
			set_feet_animation("run")
	else:
		set_arms_animation()
		set_feet_animation()
	
	velocity = velocity.normalized() * SPEED
	
	var _ms = move_and_slide(velocity, Vector2(0, -1))

func Kill():
	isDead = true
	print("PLAYER DIED!")
	$Collision_Main.free()
	$Hurtbox/CollisionShape2D.free()
	emit_signal("PlayerDie")

func IsAlive():
	return not isDead

func toogle_anim():
	_hurt.stream_paused = IsPaused()
	arms.stop()
	feet.stop()

func IsPaused():
	return get_tree().paused

func DoDamage(dmg, _actor):
	print("[PLAYER] Damage taken:  ", dmg)
	health -= dmg
	PlayerStats.health = health
	if _hurt.is_playing():
		_hurt.stop()
	if Settings.Sounds == false:
		return
	var num = randi() % 8 + 1
	var res = load("res://sounds/PlayerPain/" + str(num) + ".mp3")
	if not res:
		return
	_hurt.stream = res
	_hurt.play()

func CheckWeaponChange():
	if len(weaponsPerKills) < 1:
		return
	var next = weaponsPerKills.front()
	if zombieKilled >= next[1]:
		currentWeapon = next[0]
		zombieKilled = 0
		weaponsPerKills.pop_front()
		current_ammo = weapons[ currentWeapon ].ammo
		PlayerStats.max_ammo = current_ammo
		PlayerStats.ammo = current_ammo
		arms.position += next[2]

func KilledZombie():
	zombieKilled += 1
	PlayerStats.kills += 1
	CheckWeaponChange()

func _on_Stair_Area_area_entered(area):
	escada = area

func _on_Stair_Area_area_exited(_area):
	escada = null

func _on_Arms_Model_animation_finished():
	if not arms.animation in watchAnimations:
		return
	forceAnim = false
	set_arms_animation()

func _on_PlayerBG_finished():
	if Settings.Background == false:
		return
	if cur_sounds.size() == 0:
		cur_sounds = bg_sounds.duplicate()
	cur_sounds.shuffle()
	_bg_sound.stream = cur_sounds.pop_front()
	_bg_sound.play()
