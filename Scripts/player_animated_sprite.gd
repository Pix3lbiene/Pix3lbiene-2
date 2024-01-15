extends AnimatedSprite2D

class_name PlayerAnimatedSprite

@onready var animation_player = $"../AnimationPlayer"
@onready var area_2d = $"../Area2D"

var frame_count = 0
func trigger_animation(velocity: Vector2, direction: int, player_mode: Player.PlayerMode):
	var animation_prefix
	match player_mode:
		Player.PlayerMode.SMALL:
			animation_prefix = "small"
		Player.PlayerMode.BIG:
			animation_prefix = "big"
		Player.PlayerMode.SHOOTING:
			animation_prefix = "shooting"
	#print_debug(animation_prefix)
	#print_debug(player_mode)
	if not get_parent().is_on_floor():
		play("%s_jump" % animation_prefix)
		
# Handle slide animations
	elif sign(velocity.x) != sign(direction) && velocity.x != 0 && direction != 0:
		play("%s_slide" % animation_prefix)
		scale.x = direction
		
	else:
	# Handle the sprite turning into the direction you're going
		if scale.x == 1 && sign(velocity.x) == -1:
			scale.x = -1
		elif scale.x == -1 && sign (velocity.x) == 1:
			scale.x = 1
	
	# Handle run and idle animations
	if velocity.x != 0:
		play("%s_run" % animation_prefix)
	else:
		play("%s_idle" % animation_prefix)


func _on_animation_finished():
	print_debug(get_parent().player_mode)
	if animation == "small_to_big":
		reset_player_properties()
		#match get_parent().player_mode:
			#Player.PlayerMode.BIG:
				#get_parent().player_mode = Player.PlayerMode.SMALL
			#Player.PlayerMode.SMALL:
				#get_parent().player_mode = Player.PlayerMode.BIG
		print_debug(get_parent().player_mode)
		
	elif animation == "small_to_shooting" || "big_to_shooting":
		reset_player_properties()
		if get_parent().invincible:
			animation_player.play("invincible")
	
	elif animation == "shoot":
		get_parent().set_physics_process(true)


func _on_frame_changed():
	if animation == "small_to_big" || animation == "small_to_shooting":
		var player_mode = get_parent().player_mode
		frame_count += 1
		
		if frame_count % 2 == 1:
			offset = Vector2(0, 0 if player_mode == Player.PlayerMode.BIG else - 8)
		else:
			offset = Vector2(0, 8 if player_mode == Player.PlayerMode.BIG else 0)
		
		
		
func reset_player_properties():
	offset = Vector2.ZERO
	get_parent().set_physics_process(true)
	get_parent().set_collision_layer_value(1, true)
	get_parent().set_collision_mask_value(2, true)
	get_parent().set_collision_mask_value(3, true)
	get_parent().set_collision_mask_value(5, true)
	area_2d.set_collision_layer_value(1, true)
	area_2d.set_collision_mask_value(3, true)
	area_2d.set_collision_mask_value(4, true)
	area_2d.set_collision_mask_value(5, true)
	area_2d.set_collision_mask_value(6, true)
	frame_count = 0


