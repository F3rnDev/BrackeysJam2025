extends AnimatedSprite2D

class_name Explosion

enum Type
{
	BulletNormal,
	BulletWall,
	Fire1,
	Fire2
}

func playExplosion(pos:Vector2, curExplosion:Type):
	global_position = pos
	
	var anim = Type.keys()[curExplosion]
	play(anim)

func _on_animation_finished() -> void:
	queue_free()
