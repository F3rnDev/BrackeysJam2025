extends AnimatedSprite2D

@export var orbit_radius: float = 30.0  # distância da arma em relação ao player
@export var data:WeaponInfo

var player: Node2D   # referência ao player
var baseoffset:Vector2 #baseoffset do player com o jogador na posição X

@onready var projectile = preload("res://Nodes/GameAssets/projectile.tscn")
@onready var explosion = preload("res://Nodes/GameAssets/bulletExplosion.tscn")
@onready var slash = preload("res://Nodes/GameAssets/slash.tscn")

var canShoot = true

@onready var attackTimer = $AttackTimer
@onready var shootPos = $ShootPos
@onready var reloadTimer = $ReloadTimer

var curMag
var curAmmo
var stopMovement = false

func _ready() -> void:
	play("default")
	player = get_parent()
	baseoffset = global_position - player.global_position
	
	setWeaponData()

func setWeaponData():
	if data == null:
		visible = false
		return
	
	#stats
	attackTimer.wait_time = data.attackSpeed
	curMag = data.magCapacity
	curAmmo = data.maxAmmo
	reloadTimer.wait_time = data.reloadSpeed
	
	#visual
	sprite_frames = data.sprite
	shootPos.position = data.shootPos
	$WeaponVerification/CollisionShape2D.position = data.collPos
	$WeaponVerification/CollisionShape2D.shape = data.collShape

func _process(delta: float) -> void:
	if not player or data == null or stopMovement:
		return
	
	rotateWeapon()
	checkShoot()

func rotateWeapon():
	var mouse_pos = get_global_mouse_position()
	var dir = (mouse_pos - player.global_position).normalized()
	rotation = dir.angle()
	
	var final_baseoffset = baseoffset
	
	if dir.x < 0:
		scale.y = -6.0
		final_baseoffset.x = -abs(baseoffset.x)
	else:
		scale.y = 6.0
		final_baseoffset.x = abs(baseoffset.x)
	
	global_position = player.global_position + final_baseoffset

func checkShoot():
	if Input.is_action_pressed("Shoot") and canShoot:
		handleShootInput()
	
	if Input.is_action_just_pressed("Reload") and data.weaponType == WeaponInfo.type.Ranged:
		reload()

func handleShootInput():
	#Check if timer isn't already playing
	if !attackTimer.is_stopped():
		return
	
	if data.weaponType == WeaponInfo.type.Ranged:
		shoot()
	else:
		attack()
	
	#Start attackTimer
	attackTimer.start()

func attack():
	#Play shoot animation
	stop()
	play("Shoot")
	
	#spawn weapon slash
	var slashInstance = slash.instantiate() as Slash
	var dir = get_global_mouse_position() - global_position
	slashInstance.setSlashParameters(shootPos.global_position, dir, Vector2(data.slashScale, data.slashScale), data.baseDmg)
	get_tree().current_scene.add_child(slashInstance)

func shoot():
	#Mag Capacity
	if curMag == 0:
		reload()
		return
	
	curMag -= 1
	print("curMag: ", curMag)
	
	#Play shoot animation
	stop()
	play("Shoot")
	
	#spawn projectile
	var projectileInstance = projectile.instantiate() as Projectile
	var dir = get_global_mouse_position() - global_position
	projectileInstance.setProjectileParameters(shootPos.global_position, dir, data.bulletSpeed, data.maxDistance, data.spriteBullet, data.baseDmg)
	projectileInstance.z_index = -1
	get_tree().current_scene.add_child(projectileInstance)
	
	#spawn weapon explosion
	var rng = randi_range(0, data.shootExplosion.size()-1)
	
	var explosionInstance = explosion.instantiate() as Explosion
	explosionInstance.playExplosion(shootPos.global_position, data.shootExplosion[rng])
	explosionInstance.rotation = rotation
	explosionInstance.offset.x = 4.0
	explosionInstance.z_index = -1
	get_tree().current_scene.add_child(explosionInstance)

func reload():
	#Mag full or no ammo
	if curMag == data.magCapacity or curAmmo == 0 or !reloadTimer.is_stopped():
		return
	
	player.setReloadBarVisible(true)
	reloadTimer.start()
	play("Reload")
	
	canShoot = false

func applyReload() -> void:
	var needed = data.magCapacity - curMag
	var to_load = min(needed, curAmmo)
	
	#apply
	curMag += to_load
	curAmmo -= to_load
	
	player.setReloadBarVisible(false)
	play("transitionIdle")
	canShoot = true
	print("RELOADED - curMag: " , curMag, " curAmmo: ", curAmmo)


func _on_animation_finished() -> void:
	if animation == "transitionIdle":
		play("default")
	else:
		play("transitionIdle")

func _on_weapon_verification_body_entered(body: Node2D) -> void:
	canShoot = false

func _on_weapon_verification_body_exited(body: Node2D) -> void:
	canShoot = true
