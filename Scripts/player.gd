extends CharacterBody2D

const SPEED = 300.0
@onready var weapon = $Weapon
@onready var reloadBar = $ReloadBar

var reloading = false

func _ready() -> void:
	setReloadBarMax()
	setReloadBarVisible(false)

func _process(delta: float) -> void:
	if reloading:
		var reloadTimer = weapon.get_node("ReloadTimer")
		reloadBar.value = reloadTimer.wait_time - reloadTimer.time_left

func _physics_process(delta: float) -> void:
	movePlayer()
	move_and_slide()

func movePlayer():
	var directionX := Input.get_axis("Left", "Right")
	var directionY := Input.get_axis("Up", "Down")
	var direction = Vector2(directionX, directionY)
	
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

#Roll
func roll():
	pass

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
