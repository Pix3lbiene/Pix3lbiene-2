extends Enemy

func die():
	super.die() # Calls base code from enemy class
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
