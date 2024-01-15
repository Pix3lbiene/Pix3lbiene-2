extends Node2D

@export var start_level: String
@onready var player = $Player

@onready var levels = $Levels

var current_level: Node2D
var overworld: Node2D

signal end_game

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level = load(start_level).instantiate()
	levels.add_child(current_level)
	player.global_position = current_level.get_node('SpawnMarker').global_position
	


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
