extends KinematicBody2D

signal ZombieDie

const SPEED = 40
const DAMAGE = 10

onready var _sound = $Zombie_Sound
onready var _pain = $Model/Hurt
onready var health_bar = $HealthBar
onready var hpcount = $HealthBar/Count

const drop = preload("res://scenes/ItemDrop.tscn")

var blood

var health = 100
var velocity = Vector2()
var lastShoot = Time
var change_anim = true

var path = []
var nav : Navigation2D = null setget set_nav 

var isDead = false
var first = true
var bloodGone = false
var player
var collider

func _ready():
	# warning-ignore:return_value_discarded
	Settings.connect("sound_stats_changed", self, "set_sound_stats")
	scale = Vector2(0.5, 0.5)
	$Model.animation = "idle"
	
	health_bar.self_modulate.r = 1
	health_bar.self_modulate.g = 0.2
	health_bar.self_modulate.b = 0.5
	
	var font = DynamicFont.new()
	font.font_data = load("res://fonts/zombie_blood.ttf")
	font.size = 96
	hpcount.add_font_override("font", font)
	hpcount.rect_size = hpcount.rect_size * 10
	hpcount.rect_scale = Vector2(0.1, 0.1)
	
	health_bar.max_value = health
	health_bar.value = health

func set_sound_stats(stats):
	if player:
		if stats:
			_sound.play()
		else:
			_sound.stop()

func set_nav(new_nav):
	nav = new_nav
	update_path()

func update_path():
	if not player:
		return
	if not player.IsAlive():
		return
	
	if player.IsPaused():
		return
	if not nav:
		return
	path = nav.get_simple_path(global_position, player.global_position, false)

func _on_Recalculate_Route_timeout():
	update_path()

func _physics_process(delta):
	if isDead:
		if first:
			return
		if bloodGone and blood:
			blood.modulate.a = $Timer.time_left/5
			return
		$Model.modulate.a = $Timer.time_left/3
		return
	
	if not player:
		return
	if not player.IsAlive():
		return
	
	if player.IsPaused():
		return

	var plpos = player.get_position()
	
	
	if !path.empty():
		var next_point = path[0]
		$Model.look_at(next_point)
		var distance_to_next_point = position.distance_to(next_point)
		if distance_to_next_point < 2:
			path.remove(0)
		else:
			set_position(position.linear_interpolate(next_point, (SPEED * delta)/distance_to_next_point))
	else:
		$Model.look_at(plpos)
		var ang = position.angle_to_point(plpos) - PI
		velocity.x = SPEED*cos(ang)
		velocity.y = SPEED*sin(ang)
	
	if change_anim:
		$Model.animation = "move"
	
	var _ms = move_and_slide(velocity)
	


func Kill():
	if player:
		var item = drop.instance()
		
		player.get_parent().add_child_below_node(player.get_parent().get_node("Drops"), item)
		if not item.Deploy(player, self):
			print("Item removido")
			item.queue_free()
		else:
			print("Item spawnado")
	
	var bloodStain = Sprite.new()
	add_child_below_node($Timer, bloodStain)
	
	var texture = ResourceLoader.load("res://image/sprites/blood_stain.png")
	bloodStain.texture = texture
	
	bloodStain.scale = Vector2(0.1, 0.1)
	
	blood = bloodStain
	
	hpcount.text = "Morto"
	
	$Model.playing = false
	
	_sound.stop()
	if Settings.Sounds:
		_sound.stream = load("res://sounds/zombie_death.wav")
		_sound.play()
	
	if $Collision:
		$Collision.free()
	if $Hurtbox:
		$Hurtbox.free()
	if $VisionArea:
		$VisionArea.free()
	isDead = true
	$Timer.start(1)

func toogle_anim():
	_sound.stream_paused = IsPaused()
	_pain.stream_paused = IsPaused()
	$Model.stop()

func toogle_fade_timer():
	if not isDead:
		return
	$Timer.paused = IsPaused()

func IsAlive():
	return not isDead

func IsPaused():
	if not player:
		return true
	return player.IsPaused()

func DoDamage(dmg, _actor : KinematicBody2D = null):
	if player:
		if player.IsPaused():
			return
	if not _actor:
		return
	print("[ZOMBIE] Damage taken! ", dmg)
	_sound.stream_paused = true
	if Settings.Sounds:
		_pain.play()
	health -= dmg
	health_bar.value = health
	
	hpcount.text = str(health_bar.value)+"/"+str(health_bar.max_value)
	if health <= 0:
		emit_signal("ZombieDie", _actor)
		Kill()

func _on_Timer_timeout():
	if not first:
		if bloodGone:
			queue_free()
		bloodGone = true
		$Timer.start(5)
		return
	first = false
	$Timer.start(3)

func _on_VisionArea_area_entered(area):
	player = area.get_parent()
	update_path()
	if not _sound.playing and not _sound.stream_paused:
		if Settings.Sounds:
			_sound.play()

func _on_Model_animation_finished():
	if $Model.animation == "attack":
		change_anim = true
		if collider:
			collider.DoDamage(DAMAGE, self)
			$Atk_Cooldown.start(1)

func _on_Atk_Cooldown_timeout():
	if collider:
		$Model.animation = "attack"
		change_anim = false

func _on_Hurt_finished():
	_pain.stop()
	_sound.stream_paused = false

func _on_Hurtbox_body_entered(body):
	if body == self:
		return
	if body.has_method("DoDamage") and collider == null:
		collider = body
		$Model.animation = "attack"
		change_anim = false

func _on_Hurtbox_body_exited(body):
	if body == collider:
		collider = null
