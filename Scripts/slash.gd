extends AnimatedSprite2D

class_name Slash

var slashDamage:float = 1.0

var dir:Vector2

func setSlashParameters(spawnPos:Vector2, dir:Vector2, slashScale:Vector2, slashDamage:float):
	global_position = spawnPos
	rotation = dir.angle()
	self.dir = dir
	scale = slashScale
	self.slashDamage = slashDamage
	play("default")

func _on_animation_finished() -> void:
	queue_free()


func _on_area_collider_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		var enemy = area.get_parent()
		var behaviour = enemy.get_node("GlobalBehaviour")
		behaviour.receiveHit(slashDamage, dir)
