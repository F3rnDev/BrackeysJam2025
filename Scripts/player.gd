extends CharacterBody2D

const SPEED = 300.0
@onready var weapon = $Weapon

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
