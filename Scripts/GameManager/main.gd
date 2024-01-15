extends Node

@export var game_scene: String
var game_world: Node2D
var instantiated_game_world: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	
	ScreenFader.fade_in()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_game_load():
	ScreenFader.fade_out()
	await(ScreenFader.faded_out)
	# Die Spiel-Welt instanzieren und dann zur Main-Node hinzufügen
	# Nur dann instanzieren, wenn sie nicht vorher schon mal geladen wurde
	if !instantiated_game_world:
		instantiated_game_world = true
		game_world = load(game_scene).instantiate()
		add_child(game_world)
		game_world.connect('end_game', open_main_menu)
	else:
		add_child(game_world)
	BackgroundMusic.play_music("res://Assets/Sound/Music/main_loop.wav")
	ScreenFader.fade_in()
	

func open_main_menu():
	ScreenFader.fade_out()
	remove_child(game_world)
	get_tree().paused = false
	
	var main_menu = load("res://Nodes/MainMenu/Title.tscn").instantiate()
	add_child(main_menu)
	main_menu.connect('starting', _on_game_load)
	ScreenFader.fade_in()
	