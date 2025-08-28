extends CharacterBody2D

const SPEED = 300.0
@onready var weapon = $Weapon
@onready var reloadBar = $ReloadBar

var reloading = false

var health = 3.0
var invincible = false

#Dashing
@export var DASHSPEED: float = 700.0
var dashing = false

func _ready() -> void:
	setReloadBarMax()
	setReloadBarVisible(false)

func _process(delta: float) -> void:
	if reloading:
		var reloadTimer = weapon.get_node("ReloadTimer")
		reloadBar.value = reloadTimer.wait_time - reloadTimer.time_left
	
	if dashing:
		spawn_afterimage()

func _physics_process(delta: float) -> void:
	movePlayer()
	move_and_slide()

func movePlayer():
	var directionX := Input.get_axis("Left", "Right")
	var directionY := Input.get_axis("Up", "Down")
	var direction = Vector2(directionX, directionY)
	
	var speed = SPEED
	if dashing:
		speed = DASHSPEED
	
	if direction:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if Input.is_action_just_pressed("Roll") and direction:
		roll()

#Roll
func roll():
	if !$DashCooldown.is_stopped():
		return
	
	dashing = true
	invincible = true
	$DashTimer.start()

#ReloadBar
func setReloadBarMax():
	if weapon.data == null:
		return
	
	reloadBar.max_value = weapon.data.reloadSpeed

func setReloadBarVisible(boolean):
	reloadBar.visible = boolean
	
	if weapon.data == null:
		return
	
	reloading = boolean
	reloadBar.value = 0

#Health
func hit(dir):
	if invincible:
		return
	
	health -= 0.5
	invincible = true
	print("PLAYERHIT: ", health)
	
	if health <= 0:
		kill()
		return
	
	#Animate enemy receiving damage
	var animation = $hitAnimation as AnimationPlayer
	animation.play("hit")
	
	#TimeFreeze
	timeFreeze(0.0, 0.1)
	
	#startBlink
	$IFrames.start()

func timeFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	$Weapon.stopMovement = true
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
	$Weapon.stopMovement = false

func kill():
	#GAME OVER
	queue_free()

#AfterImage
func spawn_afterimage():
	var ghost := Sprite2D.new()
	# Copia a aparência do jogador
	#ghost.texture = $AnimatedSprite2D.sprite_frames.get_frame_texture(
		#$AnimatedSprite2D.animation,
		#$AnimatedSprite2D.frame
	#)
	ghost.texture = $Icon.texture #placeholder
	ghost.flip_h = $Icon.flip_h
	ghost.scale = $Icon.scale
	ghost.global_position = $Icon.global_position
	ghost.rotation = rotation
	ghost.modulate = Color(0.49, 0.96, 0.82, 0.2)
	ghost.z_index = $Icon.z_index - 1
	get_parent().add_child(ghost)
	
	var tween := get_tree().create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tween.tween_callback(Callable(ghost, "queue_free"))

#Signals
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		var dir = area.get_parent().global_position - global_position
		hit(dir)

func _on_hit_animation_animation_finished(anim_name: StringName) -> void:
	$hitAnimation.play("blink")

func _on_i_frames_timeout() -> void:
	$hitAnimation.stop()
	invincible = false

func _on_dash_timer_timeout() -> void:
	dashing = false
	invincible = false
	$DashCooldown.start()
