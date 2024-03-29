extends Area2D

class_name Enemy

const POINTS_LABEL_SCENE = preload("res://Scenes/points_label.tscn")
@export var horizontal_speed = 20
@export var vertical_speed = 100

@onready var ground_raycast = $GroundRaycast as RayCast2D
@onready var left_raycast = $LeftRaycast as RayCast2D
@onready var right_raycast = $RightRaycast as RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D

@export var enemy_no_collision_frames = 0

var already_hit = false


func _process(delta):
		
	position.x -= delta * horizontal_speed
	
	if sign(horizontal_speed) == 1 && left_raycast.is_colliding():
		horizontal_speed = horizontal_speed*-1.0
	elif sign(horizontal_speed) == -1 && right_raycast.is_colliding():	
		horizontal_speed = horizontal_speed*-1.0
	
	
	#if !ground_raycast.is_colliding():
		#position.y += gravity * delta 
		
	if sign(animated_sprite_2d.scale.x) == 1 && sign(horizontal_speed) == -1:
			animated_sprite_2d.scale.x = animated_sprite_2d.scale.x*-1
	elif sign(animated_sprite_2d.scale.x) == -1 && sign (horizontal_speed) == 1:
			animated_sprite_2d.scale.x = abs(animated_sprite_2d.scale.x)
		


func die():
	horizontal_speed = 0
	vertical_speed = 0
	animated_sprite_2d.play("dead")
	get_parent().get_parent().get_parent().add_points(100)
	
func die_from_hit():
	if !already_hit:
		set_collision_layer_value(3, false)
		set_collision_mask_value(3, false)
		already_hit = true
		
		rotation_degrees = 180
		vertical_speed = 0
		horizontal_speed = 0
		
		var die_tween = get_tree().create_tween()
		die_tween.tween_property(self, "position", position + Vector2(0, -25), .2)
		die_tween.chain().tween_property(self, "position", position + Vector2(0, 500), 4)
		
		var points_label = POINTS_LABEL_SCENE.instantiate()
		points_label.position = self.position + Vector2(-20, -20)
		get_tree().root.add_child(points_label)
		get_parent().get_parent().get_parent().add_points(100)
		
	
func _on_area_entered(area):
	if area is Koopa and (area as Koopa).in_a_shell and (area as Koopa).horizontal_speed != 0:
		die_from_hit()
	
	
	
