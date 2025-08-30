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

@export var canOverlap = false

#Knockback
@export var has_knockback:bool = true
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
	
	for other in get_tree().get_nodes_in_group("Enemy"):
		if canOverlap:
			break
		
		if other == self:
			continue
		var dist = enemy.global_position.distance_to(other.global_position)
		if dist < 25: # raio mínimo
			var push = (enemy.global_position - other.global_position).normalized() * 50.0 * delta
			enemy.global_position += push

func receiveHit(amount, dir):
	#Set enemy health
	health -= amount
	
	if health <= 0:
		kill()
		return
	
	#Animate enemy receiving damage
	var animation = enemy.get_node("hitAnimation") as AnimationPlayer
	animation.stop()
	animation.play("hit")
	
	#Apply Knockback
	if has_knockback:
		knockback = dir.normalized() * knockback_force

func kill():
	enemy.stop = true
	enemy.playDeath()
	
	enemy.queue_free()
