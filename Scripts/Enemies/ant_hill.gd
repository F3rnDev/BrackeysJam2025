extends CharacterBody2D

@onready var bulletExplosion = preload("res://Nodes/GameAssets/bulletExplosion.tscn")
@onready var antRef = preload("res://Nodes/Enemys/ant.tscn")
@onready var behaviorRef = $GlobalBehaviour

var stop = false
var insideSpawn = false

var playerRef:CharacterBody2D

var canSpawn = false

func _ready() -> void:
	$AnimatedSprite2D.play("Idle")

func _physics_process(delta: float) -> void:
	if stop:
		return
	
	if insideSpawn:
		behaviorRef.curState = behaviorRef.state.ALERT
	else:
		behaviorRef.curState = behaviorRef.state.IDLE
	
	match behaviorRef.curState:
		behaviorRef.state.IDLE:
			IdleState()
		behaviorRef.state.ALERT:
			AlertState()
	
	if not $SpawnTimer.is_stopped():
		var ratio = 1.0 - ($SpawnTimer.time_left / $SpawnTimer.wait_time)
		$AnimatedSprite2D.speed_scale = lerp(1.0, 5.0, ratio)
		
		$AnimatedSprite2D.material.set_shader_parameter("hint", lerp(0.0, 0.5, ratio))
		$AnimatedSprite2D.material.set_shader_parameter("sourceColor", Color.RED)
	elif $SpawnTimer.is_stopped() and behaviorRef.curState == behaviorRef.state.ALERT:
		$AnimatedSprite2D.speed_scale = lerp($AnimatedSprite2D.speed_scale, 1.0, 3.0 * delta)
		var current_hint = $AnimatedSprite2D.material.get_shader_parameter("hint")
		$AnimatedSprite2D.material.set_shader_parameter("hint", lerp(current_hint, 0.0, 3.0 * delta))
		var current_color = $AnimatedSprite2D.material.get_shader_parameter("sourceColor")
		$AnimatedSprite2D.material.set_shader_parameter("sourceColor", current_color.lerp(Color.WHITE, 3.0 * delta))
	
	move_and_slide()

func IdleState():
	pass

func AlertState():
	if !$SpawnTimer.is_stopped():
		return
	
	$SpawnTimer.start()
	#Spawnar formiguinhas
	var rngSpawn = randi_range(4, 7)
	for antID in range(rngSpawn):
		var antInstance = antRef.instantiate()
		antInstance.global_position = global_position
		antInstance.playerRef = playerRef
		get_tree().current_scene.add_child(antInstance)
	
	$AnimatedSprite2D.play("Shoot")

#playDeath
func playDeath():
	var explosionInstance = bulletExplosion.instantiate() as Explosion
	explosionInstance.playExplosion(global_position, Explosion.Type.Enemy)
	explosionInstance.scale = Vector2(6.0, 6.0)
	get_tree().current_scene.add_child(explosionInstance)

#Signals
func _on_alert_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		insideSpawn = true
		playerRef = area.get_parent()

func _on_alert_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		insideSpawn = false

func _on_animated_sprite_2d_animation_finished() -> void:
	$AnimatedSprite2D.play("Idle")
