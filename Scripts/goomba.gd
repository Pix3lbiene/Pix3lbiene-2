extends Enemy

func die():
	super.die() # Calls base code from enemy class
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
