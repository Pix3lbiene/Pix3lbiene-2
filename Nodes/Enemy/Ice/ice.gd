extends Enemy

@onready var animation_player = $AnimationPlayer

func die():
	super.die()
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	animation_player.play("enemy_death")
	await animation_player.animation_finished
	queue_free()
