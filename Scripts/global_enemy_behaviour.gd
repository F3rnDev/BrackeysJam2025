extends Node

@onready var enemy = get_parent()
@export var health:float = 5.0

#enemyState
enum state{
	IDLE,
	ALERT,
	ATTACKING
}

@export var curState = state.IDLE

#Knockback
@export var knockback_force: float = 300.0
@export var knockback_decay: float = 800.0

var knockback: Vector2 = Vector2.ZERO

func _physics_process(delta):
	if knockback.length() > 1.0:
		enemy.velocity = knockback
		knockback = knockback.move_toward(Vector2.ZERO, knockback_decay * delta)
	else:
		knockback = Vector2.ZERO
		enemy.velocity = knockback

func receiveHit(amount, dir):
	#Set enemy health
	health -= amount
	
	if health <= 0:
		kill()
		return
	
	#Animate enemy receiving damage
	var animation = enemy.get_node("hitAnimation") as AnimationPlayer
	animation.play("hit")
	
	#Apply Knockback
	knockback = dir.normalized() * knockback_force

func kill():
	enemy.stop = true
	enemy.playDeath()
	
	enemy.queue_free()
