extends Node2D

@export var START_LEVEL: String

@onready var levels = $Levels
@onready var player = $Player
@onready var level_announcer = $"Level-Announcer"
@onready var level_announcer_canvas = $"Level-Announcer/CanvasLayer"
@onready var world_cam = $WorldCam

@onready var life_counter_annoucer = $"Level-Announcer/CanvasLayer/CenterContainer/VBoxContainer/HBoxContainer/life_counter"
@onready var coins_counter = $UI/coins/HBoxContainer/MarginContainer/HBoxContainer/coins_counter
@onready var heart_counter = $UI/heart/HBoxContainer/MarginContainer/HBoxContainer/heart_counter
@onready var points_label = $UI/points/points_label
@onready var ui = $UI
@onready var game_over = $GameOver


@onready var announcer_level_label = $"Level-Announcer/CanvasLayer/CenterContainer/VBoxContainer/HBoxContainer2/level_path"


@export var current_level: Node2D

@export var lifes = 3
@export var coins = 0
@export var score = 0

var overworld: Node2D
var underground: Node2D
var paused = false

signal end_game(won: bool)

# Called when the node enters the scene tree for the first time.

func _ready():
	levels.visible = false
	
	lifes = 3
	coins = 0
	score = 0
	
	remove_child(player)
	level_announcer_canvas.visible = true
	ui.visible = false
	game_over.visible = false
	
	current_level = load(START_LEVEL).instantiate()
	update_labels()
	
	ScreenFader.fade_in()
	
	var timer = get_tree().create_timer(3)
	await(timer.timeout)
	ScreenFader.fade_out()
	await(ScreenFader.faded_out)
	add_child(player)
	player.global_position = current_level.get_node('SpawnMarker').global_position
	player.set_physics_process(false)
	levels.add_child(current_level)
	levels.visible = true
	
	check_camera_setup()
	level_announcer_canvas.visible = false
	ScreenFader.fade_in()
	
	BackgroundMusic.play_music("res://Assets/Sound/Music/main_loop.wav")
	ui.visible = true
	player.set_physics_process(true)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("exit"):
		if(paused):
			paused = false
			ScreenFader.fade_from_gray_to_white()
			await(ScreenFader.faded_in)
			BackgroundMusic.process_mode = Node.PROCESS_MODE_INHERIT
			levels.process_mode = Node.PROCESS_MODE_INHERIT
			level_announcer.process_mode = Node.PROCESS_MODE_INHERIT
			player.process_mode = Node.PROCESS_MODE_INHERIT
			
		else:
			paused = true
			BackgroundMusic.process_mode = Node.PROCESS_MODE_DISABLED
			levels.process_mode = Node.PROCESS_MODE_DISABLED
			level_announcer.process_mode = Node.PROCESS_MODE_DISABLED
			player.process_mode = Node.PROCESS_MODE_DISABLED
			ScreenFader.fade_to_gray()
			await(ScreenFader.faded_out)
	elif event.is_action_pressed("continue"):
		levels.process_mode = Node.PROCESS_MODE_INHERIT


func _on_pipe_switch(destination, die_here):
	overworld = current_level
	current_level = load(destination).instantiate()
	levels.remove_child(overworld)
	levels.add_child(current_level)
	var spawn_location = current_level.get_node('SpawnMarker').global_position
	player.global_position = spawn_location
	check_camera_setup()
	var timer = get_tree().create_timer(0.2)
	await(timer.timeout)
	if(!die_here):
		player.set_physics_process(true)
		levels.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		player.die_tween()
		levels.process_mode = Node.PROCESS_MODE_INHERIT
	
func _on_connector_switch(return_point: String):
	print_debug(return_point)
	underground = current_level
	levels.remove_child(underground)
	current_level = overworld
	levels.add_child(current_level)
	player.velocity = Vector2.ZERO
	player.global_position = current_level.get_node(return_point).global_position
	print_debug(player.global_position)
	check_camera_setup()
	var timer = get_tree().create_timer(0.2)
	await(timer.timeout)
	player.set_physics_process(true)
	levels.process_mode = Node.PROCESS_MODE_INHERIT
	
	

func _on_player_start_over():
	if(!lifes == 0):
		levels.remove_child(current_level)
		ui.visible = false
		current_level = load(START_LEVEL).instantiate()
		levels.add_child(current_level)
		check_camera_setup()
		player.global_position = current_level.get_node('SpawnMarker').global_position
		score = 0
		coins = 0
		update_labels()
		BackgroundMusic.play()
		ui.visible = true
	else:
		game_over.visible = true
		ui.visible = false
		current_level.free()
		var timer = get_tree().create_timer(4)
		await(timer.timeout)
		emit_signal("end_game", false)
		
		
		
	
func stop_level():
	current_level.process_mode = Node.PROCESS_MODE_DISABLED
	
func resume_level():
	current_level.process_mode = Node.PROCESS_MODE_INHERIT

func check_camera_setup():
	world_cam.global_position = Vector2.ZERO
	if current_level.find_child("camera_start") && current_level.find_child("camera_end"):
		player.start_position=current_level.find_child("camera_start")
		player.end_position=current_level.find_child("camera_end")
		player.should_camera_sync = true
	else:
		player.should_camera_sync = false
	
func update_labels():
	announcer_level_label.text = current_level.level_name
	life_counter_annoucer.text = str(lifes).pad_zeros(2)
	coins_counter.text = str(coins).pad_zeros(2)
	heart_counter.text = str(lifes).pad_zeros(2)
	points_label.text = str(score).pad_zeros(6)
	
func add_points(amount: float):
	score += amount
	update_labels()
	
func add_coins(amount: float):
	coins += amount
	update_labels()
	
func add_lifes(amount: float):
	lifes += amount
	update_labels()

func player_won():
	emit_signal("end_game", true)
