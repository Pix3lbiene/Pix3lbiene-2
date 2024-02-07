extends Node2D

@export var start_level: String

@onready var levels = $Levels
@onready var player = $Player
@onready var level_announcer = $"Level-Announcer"
@onready var level_announcer_canvas = $"Level-Announcer/CanvasLayer"

@onready var announcer_level_label = $"Level-Announcer/CanvasLayer/CenterContainer/VBoxContainer/HBoxContainer2/level_path"


var current_level: Node2D
var overworld: Node2D
var underground: Node2D
var paused = false

signal end_game

# Called when the node enters the scene tree for the first time.
func _ready():
	remove_child(player)
	
	current_level = load(start_level).instantiate()
	announcer_level_label.text = current_level.level_name
	ScreenFader.fade_in()
	
	var timer = get_tree().create_timer(3)
	await(timer.timeout)
	ScreenFader.fade_out()
	await(ScreenFader.faded_out)
	add_child(player)
	player.global_position = current_level.get_node('SpawnMarker').global_position
	levels.add_child(current_level)
	level_announcer_canvas.visible = false
	ScreenFader.fade_in()


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


func _on_pipe_switch(destination):
	overworld = current_level
	current_level = load(destination).instantiate()
	levels.remove_child(overworld)
	levels.add_child(current_level)
	var spawn_location = current_level.get_node('SpawnMarker').global_position
	player.global_position = spawn_location
	var timer = get_tree().create_timer(0.2)
	await(timer.timeout)
	player.set_physics_process(true)
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
	var timer = get_tree().create_timer(0.2)
	await(timer.timeout)
	player.set_physics_process(true)
	levels.process_mode = Node.PROCESS_MODE_INHERIT

func _on_player_start_over():
	levels.remove_child(current_level)
	current_level = load(start_level).instantiate()
	levels.add_child(current_level)
	player.global_position = current_level.get_node('SpawnMarker').global_position
	
func stop_level():
	levels.get_child(0).process_mode = Node.PROCESS_MODE_DISABLED
