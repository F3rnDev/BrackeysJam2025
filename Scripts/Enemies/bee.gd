extends CharacterBody2D
@export var moveSpeed = 200.0
@export var dashSpeed = 1000.0
@export var attackDistance = 500.0

@onready var behaviorRef = %GlobalBehaviour
@onready var agent = $NavigationAgent2D

@onready var bulletExplosion = preload("res://Nodes/GameAssets/bulletExplosion.tscn")

var playerRef:CharacterBody2D #Get at moment of collision

var attackOrigin
var dir

var insideAttack = false
var stop = false

var transitionToIdle = false

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")

func _physics_process(delta: float) -> void:
	if stop:
		return
	
	if insideAttack and behaviorRef.curState != behaviorRef.state.ATTACKING:
		setUpAttack()
		behaviorRef.curState = behaviorRef.state.ATTACKING
	
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
	#Do idle shit
	pass

func AlertState():
	if behaviorRef.knockback.length() > 1.0:
		return
	
	makeNavMeshPath()
	
	dir = to_local(agent.get_next_path_position()).normalized()
	velocity = dir*moveSpeed
	$AnimatedSprite2D.flip_h = dir.x < 0
	
	$AnimatedSprite2D.play("Idle")

func Attack():
	if transitionToIdle:
		return
	
	if !$AttackTimer.is_stopped():
		dir = playerRef.global_position - global_position
		rotation = dir.angle()
		
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.flip_v = dir.x < 0
		$AnimatedSprite2D.play("Prepare")
		
		if global_position.distance_to(playerRef.global_position) >= attackDistance:
			rotation = 0
			behaviorRef.curState = behaviorRef.state.ALERT
		
		return
	
	velocity = dir.normalized()*dashSpeed
	$AnimatedSprite2D.play("Attack")
	
	var distance = global_position.distance_to(attackOrigin)
	if distance >= attackDistance or is_on_wall() or is_on_ceiling() or is_on_floor():
		goToIdle()

func setUpAttack():
	if behaviorRef.curState == behaviorRef.state.ATTACKING:
		return
	
	attackOrigin = global_position
	$AttackTimer.start()
	#startAnimation

func goToIdle():
	if transitionToIdle:
		return
	
	transitionToIdle = true
	$AnimatedSprite2D.play("Stop")

#playDeath
func playDeath():
	var explosionInstance = bulletExplosion.instantiate() as Explosion
	explosionInstance.playExplosion(global_position, Explosion.Type.Enemy)
	explosionInstance.scale = Vector2(6.0, 6.0)
	get_tree().current_scene.add_child(explosionInstance)

#Signals
func _on_alert_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player") and behaviorRef.curState == behaviorRef.state.IDLE:
		playerRef = area.get_parent()
		behaviorRef.curState = behaviorRef.state.ALERT

func _on_attack_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		insideAttack = true

func _on_attack_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		insideAttack = false


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "Stop":
		rotation = 0
		behaviorRef.curState = behaviorRef.state.ALERT
		transitionToIdle = false
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.flip_v = false
