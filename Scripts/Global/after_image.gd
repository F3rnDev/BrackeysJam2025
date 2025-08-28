extends Node2D

@export var sprite:Sprite2D #change to animated sprite later
@export var color:Color

func spawn_afterimage():
	var ghost := Sprite2D.new()
	
	#ghost.texture = $AnimatedSprite2D.sprite_frames.get_frame_texture(
		#$AnimatedSprite2D.animation,
		#$AnimatedSprite2D.frame
	#)
	
	# aparência
	ghost.texture = sprite.texture
	ghost.flip_h = sprite.flip_h
	ghost.scale = sprite.scale
	ghost.rotation = rotation
	ghost.modulate = color
	ghost.z_index = sprite.z_index - 1
	
	ghost.global_position = sprite.global_position

	# adiciona no mesmo pai do sprite
	get_parent().add_child(ghost)

	# tween para sumir
	var tween := get_tree().create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3)
	tween.tween_callback(Callable(ghost, "queue_free"))
