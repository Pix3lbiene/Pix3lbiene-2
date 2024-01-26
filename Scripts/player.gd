extends CharacterBody2D

class_name Player

signal points_scored(points: int)
signal pipe_switch(destination: String)
signal start_over


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum PlayerMode {
	SMALL,
	BIG,
	SHOOTING
}

const PIPE_ENTER_THRESHOLD = 10

# References
const POINTS_LABEL_SCENE = preload("res://Scenes/points_label.tscn")
const SMALL_MARIO_COLLISION_SHAPE = preload("res://Resources/CollisionShapes/small_mario_collision_shape.tres")
const BIG_MARIO_COLLISION_SHAPE = preload("res://Resources/CollisionShapes/big_mario_collision_shape.tres")
const FIREBALL_SCENE = preload("res://Scenes/fireball.tscn")


# On ready
@onready var animated_sprite_2d = $AnimatedSprite2D as PlayerAnimatedSprite
@onready var area_2d = $Area2D
@onready var area_collision_shape = $Area2D/AreaCollisionShape
@onready var body_collision_shape = $BodyCollisionShape
@onready var death_sound = $DeathSound
@onready var power_up_sound = $PowerUpSound
@onready var shooting_point = $ShootingPoint
@onready var animation_player = $AnimationPlayer
@onready var game_world = $".."



@export_group("Locomotion")
@export var run_speed_damping = 0.5
@export var speed = 200.0
@export var jump_velocity = -350
@export_group("")

@export_group("Stomping enemies")
@export var min_stomp_degree = 35
@export var max_stomp_degree = 145
@export var stomp_y_velocity = -150
@export_group("")

@export_group("Camera Sync")
@export var camera_sync: Camera2D
@export var start_position: Marker2D
@export var end_position: Marker2D
@export var should_camera_sync = true
@export var camera_tolerance = 40
@export_group("")

var player_mode = PlayerMode.SMALL

var next_destination: String

# Player state flags
var is_dead = false
var invincible_time = 0.0
var invincible = false

#func _ready():
	#print_debug(player_mode)
	#if SceneData.return_point != null && SceneData.return_point != Vector2.ZERO:
		#global_position = SceneData.return_point
		#player_mode = SceneData.player_mode
		#print_debug(player_mode)
		#set_collision_shapes(false if player_mode == PlayerMode.BIG || player_mode == PlayerMode.SHOOTING else true)
	
	#print_debug(player_mode)
	#set_physics_process(false)
	#animated_sprite_2d.play("spawn")
	#power_up_sound.play()
	
	


func _physics_process(delta):
	
	if(!invincible_time == 0):
		invincible = true
		invincible_time -= delta
		if(invincible_time < 0):
			invincible_time = 0
			invincible = false
			animation_player.play("RESET")
	 
	# Calculate the x-coordinates of the Viewport
	var camera_left_bound = camera_sync.global_position.x - camera_sync.get_viewport_rect().size.x / 2 / camera_sync.zoom.x
	var camera_right_bound = camera_sync.global_position.x + camera_sync.get_viewport_rect().size.x / 2 / camera_sync.zoom.x
	
	# Apply gravity
	
	
	# Durch den Input entscheiden, in welche Richtung gelaufen werden soll
	var direction = Input.get_axis("left","right")
	
		
	if direction:
		#print_debug(direction)
		#if 	!(global_position.x < camera_left_bound + 8 && sign(velocity.x) == -1) && sign(direction) == -1:
			velocity.x = lerpf(velocity.x, speed * direction, run_speed_damping * delta)
			
		#elif !(global_position.x > camera_right_bound - 8 && sign(velocity.x) == 1) && sign(direction) == 1:
			#velocity.x = lerpf(velocity.x, speed * direction, run_speed_damping * delta)
			
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		
	#When the player wants to move outside the camera, stop him
	#if 	global_position.x < camera_left_bound + 8 && sign(velocity.x) == -1:
		#velocity.x = 0.0
		#return
	#elif global_position.x > camera_right_bound - 8 && sign(velocity.x) == 1:		
		#velocity.x = 0.0
		#return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jumps
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
		
	
	
	
	
	
	
	if Input.is_action_just_pressed("shoot") && player_mode == PlayerMode.SHOOTING:
		shoot()
	else:
		animated_sprite_2d.trigger_animation(velocity, direction, player_mode)
	
	var collision = get_last_slide_collision()
	if collision != null:
		handle_movement_collision(collision)
	
	move_and_slide()

func _process(delta):
	
	# Cheat Mode
	#if Input.is_action_just_pressed("cheat"):
	#	set_physics_process(false)
	#	var fly_tween = get_tree().create_tween()
	#	fly_tween.tween_property(self, "position", position + Vector2(1200, 0), 20)
	
	
	
	# Camera only moves when player goes outside given area
	if should_camera_sync:
		# Right camera movement
		if global_position.x > camera_sync.global_position.x +camera_tolerance && end_position.global_position.x > camera_sync.global_position.x:
			camera_sync.global_position.x = global_position.x -camera_tolerance
		
		# Left camera movement
		elif global_position.x < camera_sync.global_position.x -camera_tolerance && start_position.global_position.x < camera_sync.global_position.x:
			camera_sync.global_position.x = global_position.x +camera_tolerance
	
	

func _on_area_2d_area_entered(area):
	if area is Enemy:
		handle_enemy_collision(area)
	if (area is Shroom && area.get_tree().current_scene == get_tree().current_scene):
		handle_shroom_collision(area)
		area.queue_free()
	if area is ShootingFlower:
		handle_flower_collision()
		area.queue_free()
		
func handle_enemy_collision(enemy: Enemy):
	if enemy == null && is_dead:
		return
	
	if is_instance_of(enemy, Koopa) and (enemy as Koopa).in_a_shell:
		var angle_of_collision = rad_to_deg(position.angle_to_point(enemy.position))
		print_debug(angle_of_collision)
		print_debug((enemy as Koopa).sliding)
		if angle_of_collision > min_stomp_degree && angle_of_collision < max_stomp_degree:
			on_enemy_stomped()
			spawn_points_label(enemy)
			(enemy as Koopa).on_stomp(global_position)
			print_debug("lmao")
			
		elif !(enemy as Koopa).sliding:
			(enemy as Koopa).on_stomp(global_position)
			
		elif (enemy as Koopa).sliding:
			die()

	else:
		var angle_of_collision = rad_to_deg(position.angle_to_point(enemy.position))
		
		if angle_of_collision > min_stomp_degree && max_stomp_degree > angle_of_collision:
			enemy.die()
			on_enemy_stomped()
			spawn_points_label(enemy)
		else:
			die()
		
func die():
	print_debug("trying to die")
	if(!invincible):
		if player_mode == PlayerMode.SMALL:
			is_dead = true
			animated_sprite_2d.play("death")
			area_collision_shape.process_mode = Node.PROCESS_MODE_DISABLED
			body_collision_shape.process_mode = Node.PROCESS_MODE_DISABLED
			game_world.stop_level()
			set_physics_process(false)
			
			BackgroundMusic.stop()
			death_sound.play()
		
			animation_player.play("death")
			
		
		else:
			big_to_small()
			invincible_time = 2
			invincible = true
	
func on_enemy_stomped():
	velocity.y = stomp_y_velocity
		
	
func spawn_points_label(enemy):
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = enemy.position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)
	points_scored.emit(100)
	
func handle_movement_collision(collision: KinematicCollision2D):
	if collision.get_collider() is Block:
		var collision_angle = rad_to_deg(collision.get_angle())
		if roundf(collision_angle) == 180:
			(collision.get_collider() as Block).bump(player_mode)
	
	if collision.get_collider() is Pipe:
		var collision_angle = rad_to_deg(collision.get_angle())
		if roundf(collision_angle) == 0 && Input.is_action_just_pressed("down") && absf(collision.get_collider().position.x - position.x < PIPE_ENTER_THRESHOLD && collision.get_collider().is_traversable):
			handle_pipe_collision(collision)
	
func handle_shroom_collision(_area: Node2D):
	if player_mode == PlayerMode.SMALL:
		set_physics_process(false)
		position.y -= 16
		animated_sprite_2d.play("small_to_big")
		player_mode = PlayerMode.BIG
		set_collision_shapes(false)

func handle_flower_collision():
	set_physics_process(false)
	var animation_name = "small_to_shooting" if player_mode == PlayerMode.SMALL else "big_to_shooting"
	animated_sprite_2d.play(animation_name)
	player_mode = PlayerMode.SHOOTING
	set_collision_shapes(false)

func set_collision_shapes(is_small: bool):
	var collision_shape = SMALL_MARIO_COLLISION_SHAPE if is_small else BIG_MARIO_COLLISION_SHAPE
	area_collision_shape.set_deferred("shape", collision_shape)
	body_collision_shape.set_deferred("shape", collision_shape)

func big_to_small():
	set_collision_layer_value(1, false)
	set_physics_process(false)
	var animation_name = "small_to_big" if player_mode == PlayerMode.BIG else "small_to_shooting"
	animated_sprite_2d.play(animation_name, 1.0, true)
	player_mode = PlayerMode.SMALL
	set_collision_shapes(true)

func shoot():
	animated_sprite_2d.play("shoot")
	set_physics_process(false)
	
	var fireball = FIREBALL_SCENE.instantiate()
	fireball.direction = sign(animated_sprite_2d.scale.x)
	fireball.global_position = shooting_point.global_position
	game_world.current_level.add_child(fireball)

func handle_pipe_collision(pipe_collision: KinematicCollision2D):
	velocity = Vector2.ZERO
	set_physics_process(false)
	animated_sprite_2d.trigger_animation(Vector2.ZERO, 1, player_mode)
	next_destination = pipe_collision.get_collider().destination
	var pipe_tween = get_tree().create_tween()
	pipe_tween.tween_property(self, "position", position + Vector2(pipe_collision.get_collider().position.x - position.x, 0), abs(pipe_collision.get_collider().position.x - position.x) * 0.1 / 5)
	pipe_tween.chain().tween_property(self, "position", position + Vector2(pipe_collision.get_collider().position.x - position.x, 32), 1)
	pipe_tween.tween_callback(switch_to_underground)
	
func handle_pipe_connector_entrance_collision():
	set_physics_process(false)
	var pipe_tween = get_tree().create_tween()
	pipe_tween.tween_property(self, "position", position + Vector2(32, 0), 1)
	#pipe_tween.tween_callback(switch_to_main)

func switch_to_underground():
	if next_destination:
		emit_signal("pipe_switch", next_destination)
#func switch_to_main():
	#get_tree().change_scene_to_file("res://Scenes/main.tscn")
	#SceneData.player_mode = player_mode




func _on_animation_player_animation_finished(anim_name):
	if(anim_name == "death"):
		velocity = Vector2.ZERO
		animated_sprite_2d.reset_player_properties()
		emit_signal("start_over")
