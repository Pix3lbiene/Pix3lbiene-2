extends Node2D

@export var start_level: String

@onready var levels = $Levels
@onready var player = $Player
@onready var level_announcer = $"Level-Announcer"
@onready var level_announcer_canvas = $"Level-Announcer/CanvasLayer"

@onready var announcer_level_label = $"Level-Announcer/CanvasLayer/CenterContainer/VBoxContainer/HBoxContainer2/level_path"


var current_level: Node2D
var overworld: Node2D


signal end_game

# Called when the node enters the scene tree for the first time.
func _ready():
	remove_child(player)
	
	current_level = load(start_level).instantiate()
	announcer_level_label.text = current_level.level_name
	ScreenFader.fade_in()
	
	var timer = get_tree().create_timer(6)
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
		emit_signal("end_game")


func _on_pipe_switch(destination):
	overworld = current_level
	current_level = load(destination).instantiate()
	levels.remove_child(overworld)
	levels.add_child(current_level)
	var spawn_location = current_level.get_node('SpawnMarker').global_position
	player.global_position = spawn_location
	player.set_physics_process(true)

func _on_player_start_over():
	levels.remove_child(current_level)
	current_level = load(start_level).instantiate()
	levels.add_child(current_level)
	player.global_position = current_level.get_node('SpawnMarker').global_position
