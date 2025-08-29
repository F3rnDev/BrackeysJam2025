extends AnimatedSprite2D

class_name Explosion

enum Type
{
	BulletNormal,
	BulletWall,
	Pistol_1,
	Pistol_2,
	Enemy
}

func playExplosion(pos:Vector2, curExplosion:Type):
	global_position = pos
	
	var anim = Type.keys()[curExplosion]
	play(anim)

func _on_animation_finished() -> void:
	queue_free()
