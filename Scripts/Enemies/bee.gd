extends CharacterBody2D
@export var moveSpeed = 200.0
@export var dashSpeed = 1000.0
@export var attackDistance = 500.0

@onready var behaviorRef = %GlobalBehaviour
@onready var agent = $NavigationAgent2D

var playerRef:CharacterBody2D #Get at moment of collision

var attackOrigin
var dir

var insideAttack = false

func _physics_process(delta: float) -> void:
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

func Attack():
	if !$AttackTimer.is_stopped():
		dir = playerRef.global_position - global_position
		rotation = dir.angle()
		
		if global_position.distance_to(playerRef.global_position) >= attackDistance:
			rotation = 0
			behaviorRef.curState = behaviorRef.state.ALERT
		
		return
	
	velocity = dir.normalized()*dashSpeed
	
	var distance = global_position.distance_to(attackOrigin)
	if distance >= attackDistance or is_on_wall() or is_on_ceiling() or is_on_floor():
		#Play animation
		rotation = 0
		behaviorRef.curState = behaviorRef.state.ALERT

func setUpAttack():
	if behaviorRef.curState == behaviorRef.state.ATTACKING:
		return
	
	attackOrigin = global_position
	$AttackTimer.start()
	#startAnimation

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
