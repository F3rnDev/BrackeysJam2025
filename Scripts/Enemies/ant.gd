extends CharacterBody2D

@export var health:float = 5.0

@onready var bulletExplosion = preload("res://Nodes/GameAssets/bulletExplosion.tscn")
@onready var behaviorRef = $GlobalBehaviour
@onready var agent = $NavigationAgent2D

var playerRef

@export var moveSpeed = 200.0

var stop = false

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func _physics_process(delta: float) -> void:
	if stop:
		return
	
	match behaviorRef.curState:
		behaviorRef.state.ALERT:
			AlertState()
	
	move_and_slide()

func makeNavMeshPath():
	agent.target_position = playerRef.global_position

func AlertState():
	if behaviorRef.knockback.length() > 1.0:
		return
	
	makeNavMeshPath()
	
	var dir = to_local(agent.get_next_path_position()).normalized()
	velocity = dir*moveSpeed
	$AnimatedSprite2D.rotation = dir.angle()
	$AnimatedSprite2D.flip_v = dir.x < 0.0

#playDeath
func playDeath():
	var explosionInstance = bulletExplosion.instantiate() as Explosion
	explosionInstance.playExplosion(global_position, Explosion.Type.Enemy)
	explosionInstance.scale = Vector2(6.0, 6.0)
	get_tree().current_scene.add_child(explosionInstance)
