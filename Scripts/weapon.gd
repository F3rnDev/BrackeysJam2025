extends AnimatedSprite2D

@export var orbit_radius: float = 30.0  # distância da arma em relação ao player
@export var data:WeaponInfo

var player: Node2D   # referência ao player
var baseoffset:Vector2 #baseoffset do player com o jogador na posição X

@onready var projectile = preload("res://Nodes/projectile.tscn")
@onready var explosion = preload("res://Nodes/bulletExplosion.tscn")

var canShoot = true

func _ready() -> void:
	play("default")
	player = get_parent()
	baseoffset = global_position - player.global_position

func _process(delta: float) -> void:
	if not player:
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
	if Input.is_action_just_pressed("Shoot") and canShoot:
		handleShootInput()
		shoot()

func handleShootInput():
	#if not armaCorpoACorpo
	#	shoot()
	#else
	#	attack()
	
	shoot()

func shoot():
	#Play shoot animation
	stop()
	play("Shoot")
	
	#spawn projectile
	var projectileInstance = projectile.instantiate() as Projectile
	var dir = get_global_mouse_position() - global_position
	projectileInstance.setProjectileParameters($ShootPos.global_position, dir, 600.0, 600.0)
	projectileInstance.z_index = -1
	get_tree().current_scene.add_child(projectileInstance)
	
	#spawn weapon explosion
	var random_explosion = randi_range(0, 1)
	var explosionType = Explosion.Type.Fire1
	
	if random_explosion == 1:
		explosionType = Explosion.Type.Fire2
	
	var explosionInstance = explosion.instantiate() as Explosion
	explosionInstance.playExplosion($ShootPos.global_position, explosionType)
	explosionInstance.rotation = rotation
	explosionInstance.offset.x = 4.0
	explosionInstance.z_index = -1
	get_tree().current_scene.add_child(explosionInstance)
	

func _on_animation_finished() -> void:
	play("default")

func _on_weapon_verification_body_entered(body: Node2D) -> void:
	canShoot = false

func _on_weapon_verification_body_exited(body: Node2D) -> void:
	canShoot = true
