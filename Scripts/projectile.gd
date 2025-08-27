extends CharacterBody2D

class_name Projectile

@onready var bulletExplosion = preload("res://Nodes/GameAssets/bulletExplosion.tscn")
var explosionType:Explosion.Type = Explosion.Type.BulletNormal

var dir:Vector2
var speed:float = 100.0

var maxDist:float
var spawn:Vector2

var exploded = false

func setProjectileParameters(spawnPos:Vector2, dir:Vector2, speed:float, maxDist:float, sprite:Texture):
	self.dir = dir.normalized()
	self.speed = speed
	
	spawn = spawnPos
	global_position = spawnPos
	
	self.maxDist = maxDist
	
	rotation = dir.angle()
	
	$Sprite2D.texture = sprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = dir * speed
	var curDistance = global_position.distance_to(spawn)
	
	if curDistance >= maxDist:
		kill()
	
	if $RayCast2D.is_colliding():
		explosionType = Explosion.Type.BulletWall
		kill($RayCast2D.get_collision_point())
	
	move_and_slide()

func _on_collision_area_entered(area: Area2D) -> void:
	if !area.is_in_group("Weapon"):
		kill()

func kill(explosionPos:Vector2 = global_position):
	if !exploded:
		exploded = true
		
		var explosionInstance = bulletExplosion.instantiate() as Explosion
		explosionInstance.playExplosion(explosionPos, explosionType)
		
		# calcula o ângulo da direção da bala
		if explosionType == Explosion.Type.BulletWall:
			var angle = $RayCast2D.get_collision_normal().angle() + PI
			var snapped_angle = round(angle / (PI/2)) * (PI/2)
			explosionInstance.rotation = snapped_angle
		
		get_tree().current_scene.add_child(explosionInstance)
		queue_free()
