extends CharacterBody2D
@export var moveSpeed = 200.0
@export var attackDistance = 100.0

@onready var behaviorRef = $GlobalBehaviour
@onready var agent = $NavigationAgent2D

@onready var bulletExplosion = preload("res://Nodes/GameAssets/bulletExplosion.tscn")

var playerRef:CharacterBody2D #Get at moment of collision

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
	pass

func AlertState():
	if behaviorRef.knockback.length() > 1.0:
		return
	
	makeNavMeshPath()
	
	var dir = to_local(agent.get_next_path_position()).normalized()
	velocity = dir*moveSpeed
	$AnimatedSprite2D.flip_h = dir.x < 0
	
	$AnimatedSprite2D.play("Idle")

func Attack():
	pass

#DEATH
func playDeath():
	var explosionInstance = bulletExplosion.instantiate() as Explosion
	explosionInstance.playExplosion(global_position, Explosion.Type.Enemy)
	explosionInstance.scale = Vector2(9.0, 9.0)
	get_tree().current_scene.add_child(explosionInstance)
