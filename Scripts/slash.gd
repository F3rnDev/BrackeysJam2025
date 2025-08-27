extends AnimatedSprite2D

class_name Slash

func setSlashParameters(spawnPos:Vector2, dir:Vector2):
	global_position = spawnPos
	rotation = dir.angle()
	play("default")

func _on_animation_finished() -> void:
	queue_free()
