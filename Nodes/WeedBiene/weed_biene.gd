extends AnimatedSprite2D

@onready var player = $"../Player"
@export var camera_sync: Camera2D
@export var start_position: Marker2D
@export var end_position: Marker2D
@export var should_camera_sync = true
@export var camera_tolerance = 40
# Called when the node enters the scene tree for the first time.
func _ready():
	BackgroundMusic.play_music("res://Assets/Sound/Music/weed_music.wav")
	var timer = get_tree().create_timer(1)
	await(timer.timeout)
	play("flying")
	var fly_tween = get_tree().create_tween()
	fly_tween.tween_property(self, "position", position + Vector2(2033 - global_position.x, 0), 15)
	fly_tween.tween_callback(fly_finish)

func _process(delta):
	if should_camera_sync:
		# Right camera movement
		
		if global_position.x > camera_sync.global_position.x +camera_tolerance && end_position.global_position.x > camera_sync.global_position.x:
			camera_sync.global_position.x = global_position.x -  camera_tolerance
		# Left camera movement
		elif global_position.x < camera_sync.global_position.x -camera_tolerance && start_position.global_position.x < camera_sync.global_position.x:
			camera_sync.global_position.x = global_position.x +  camera_tolerance

func _on_area_2d_area_entered(area):
	if area is FlagPole:
		area.hit()
		get_parent().add_points(100000)
		get_parent().add_lifes(100)
		
func fly_finish():
	
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.global_position = global_position
	player.velocity = Vector2.ZERO
	player.set_physics_process(true)
	player.animated_sprite_2d.visible = true
	BackgroundMusic.play_music("res://Assets/Sound/Music/main_loop.wav")
	queue_free()
	
