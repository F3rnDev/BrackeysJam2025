extends CharacterBody2D
@export var moveSpeed = 200.0
@export var shootSpeed = 600.0
@export var shootDistance:float = 300.0
@export var bulletImage:Texture2D

@onready var behaviorRef = $GlobalBehaviour
@onready var agent = $NavigationAgent2D
@onready var bullet = preload("res://Nodes/GameAssets/projectile.tscn")
@onready var bulletExplosion = preload("res://Nodes/GameAssets/bulletExplosion.tscn")

var playerRef

var stop = false

func _physics_process(delta: float) -> void:
	if stop:
		return
	
	match behaviorRef.curState:
		behaviorRef.state.IDLE:
			IdleState()
		behaviorRef.state.ALERT:
			AlertState()
		behaviorRef.state.ATTACKING:
			Attack()
	
	move_and_slide()

func makeNavMeshPath():
	agent.target_position = playerRef.global_position

#STATES
func IdleState():
	$AnimatedSprite2D.play("Idle")
	pass

func AlertState():
	if behaviorRef.knockback.length() > 1.0:
		return
	
	makeNavMeshPath()
	
	var dir = to_local(agent.get_next_path_position()).normalized()
	velocity = dir*moveSpeed
	$AnimatedSprite2D.flip_h = dir.x < 0
	
	$AnimatedSprite2D.play("Idle")
	
	#CHECK PLAYER DISTANCE
	if global_position.distance_to(playerRef.global_position) <= shootDistance:
		behaviorRef.curState = behaviorRef.state.ATTACKING

func Attack():
	#BackToIdle
	if global_position.distance_to(playerRef.global_position) > shootDistance:
		behaviorRef.curState = behaviorRef.state.ALERT
	
	if !$AttackTimer.is_stopped():
		return
	
	$AttackTimer.start()
	$AnimatedSprite2D.play("Attack")

#playDeath
func playDeath():
	var explosionInstance = bulletExplosion.instantiate() as Explosion
	explosionInstance.playExplosion(global_position, Explosion.Type.Enemy)
	explosionInstance.scale = Vector2(6.0, 6.0)
	get_tree().current_scene.add_child(explosionInstance)

#SIGNALS
func _on_alert_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and behaviorRef.curState == behaviorRef.state.IDLE:
		playerRef = area.get_parent()
		behaviorRef.curState = behaviorRef.state.ALERT

func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.play("Idle")


func _on_animated_sprite_2d_frame_changed() -> void:
	var animation = $AnimatedSprite2D.animation
	var frame = $AnimatedSprite2D.frame
	
	if frame == 3 and animation == "Attack":
		#Spawn Shoot
		var dir = playerRef.global_position - global_position
		var bulletInstance = bullet.instantiate() as Projectile
		bulletInstance.scale = Vector2(1.5, 1.5)
		bulletInstance.setProjectileParameters(global_position, dir, 400.0, 600.0, bulletImage, 1.0, "Player")
		get_tree().current_scene.add_child(bulletInstance)
